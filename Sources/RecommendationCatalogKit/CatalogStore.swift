import Foundation

public protocol CatalogDataFetching: Sendable {
    func data(from url: URL) async throws -> Data
}

public struct URLSessionCatalogDataFetcher: CatalogDataFetching {
    public init() {}

    public func data(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CatalogStoreError.invalidHTTPResponse
        }
        return data
    }
}

public struct RecommendationCatalogConfiguration: Sendable {
    public let documentURL: URL
    public let signatureURL: URL
    public let publicKeyBase64: String
    public let cacheDirectory: URL

    public init(documentURL: URL, signatureURL: URL, publicKeyBase64: String, cacheDirectory: URL) {
        self.documentURL = documentURL
        self.signatureURL = signatureURL
        self.publicKeyBase64 = publicKeyBase64
        self.cacheDirectory = cacheDirectory
    }
}

public enum CatalogRefreshResult: Equatable {
    case updated(CatalogDocument)
    case unchanged
    case rejected
}

public actor CatalogStore {
    private let configuration: RecommendationCatalogConfiguration
    private let fetcher: any CatalogDataFetching
    private let bundledDocument: CatalogDocument?
    private let fileManager: FileManager
    private var activeDocument: CatalogDocument?

    public init(
        configuration: RecommendationCatalogConfiguration,
        fetcher: any CatalogDataFetching = URLSessionCatalogDataFetcher(),
        bundledDocument: CatalogDocument? = nil,
        fileManager: FileManager = .default
    ) {
        self.configuration = configuration
        self.fetcher = fetcher
        self.bundledDocument = bundledDocument
        self.fileManager = fileManager
    }

    public func loadInitialDocument() throws -> CatalogDocument {
        if let activeDocument {
            return activeDocument
        }

        let bundled = try bundledDocument ?? CatalogBundledSnapshot.load()
        let cached = try? loadVerifiedCache()
        let selected = (cached?.revision ?? -1) > bundled.revision ? cached! : bundled
        activeDocument = selected
        return selected
    }

    public func refresh() async -> CatalogRefreshResult {
        let currentDocument: CatalogDocument
        do {
            currentDocument = try loadInitialDocument()
        } catch {
            return .rejected
        }

        do {
            async let documentData = fetcher.data(from: configuration.documentURL)
            async let signatureData = fetcher.data(from: configuration.signatureURL)
            let (downloadedDocumentData, downloadedSignatureData) = try await (documentData, signatureData)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let signature = try decoder.decode(CatalogSignature.self, from: downloadedSignatureData)
            try CatalogSignatureVerifier.verify(
                documentData: downloadedDocumentData,
                signature: signature,
                publicKeyBase64: configuration.publicKeyBase64
            )
            let downloadedDocument = try decoder.decode(CatalogDocument.self, from: downloadedDocumentData)

            guard downloadedDocument.revision > currentDocument.revision else {
                return .unchanged
            }

            try persist(documentData: downloadedDocumentData, signatureData: downloadedSignatureData)
            activeDocument = downloadedDocument
            return .updated(downloadedDocument)
        } catch {
            return .rejected
        }
    }

    private func loadVerifiedCache() throws -> CatalogDocument {
        let documentData = try Data(contentsOf: cacheDocumentURL)
        let signatureData = try Data(contentsOf: cacheSignatureURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let signature = try decoder.decode(CatalogSignature.self, from: signatureData)
        try CatalogSignatureVerifier.verify(
            documentData: documentData,
            signature: signature,
            publicKeyBase64: configuration.publicKeyBase64
        )
        return try decoder.decode(CatalogDocument.self, from: documentData)
    }

    private func persist(documentData: Data, signatureData: Data) throws {
        try fileManager.createDirectory(at: configuration.cacheDirectory, withIntermediateDirectories: true)
        try documentData.write(to: cacheDocumentURL, options: .atomic)
        try signatureData.write(to: cacheSignatureURL, options: .atomic)
    }

    private var cacheDocumentURL: URL {
        configuration.cacheDirectory.appendingPathComponent("recommendations.json")
    }

    private var cacheSignatureURL: URL {
        configuration.cacheDirectory.appendingPathComponent("recommendations.sig")
    }
}

public enum CatalogStoreError: Error, Equatable {
    case invalidHTTPResponse
}
