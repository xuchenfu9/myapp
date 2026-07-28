import CryptoKit
import XCTest
@testable import RecommendationCatalogKit

final class CatalogStoreTests: XCTestCase {
    func testRefreshAcceptsOnlyNewerSignedDocument() async throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let initial = CatalogDocument(schemaVersion: 2, revision: 1, apps: [])
        let remote = CatalogDocument(schemaVersion: 2, revision: 2, apps: [])
        let encoder = JSONEncoder()
        let remoteData = try encoder.encode(remote)
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 2,
            signature: try privateKey.signature(for: remoteData).base64EncodedString()
        )
        let signatureData = try encoder.encode(signature)
        let documentURL = URL(string: "https://example.invalid/catalog/recommendations.json")!
        let signatureURL = URL(string: "https://example.invalid/catalog/recommendations.sig")!
        let cacheDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        let store = CatalogStore(
            configuration: RecommendationCatalogConfiguration(
                documentURL: documentURL,
                signatureURL: signatureURL,
                publicKeyBase64: privateKey.publicKey.rawRepresentation.base64EncodedString(),
                cacheDirectory: cacheDirectory
            ),
            fetcher: StubCatalogFetcher(dataByURL: [documentURL: remoteData, signatureURL: signatureData]),
            bundledDocument: initial
        )

        let initialDocument = try await store.loadInitialDocument()
        let refreshResult = await store.refresh()
        let refreshedDocument = try await store.loadInitialDocument()

        XCTAssertEqual(initialDocument, initial)
        XCTAssertEqual(refreshResult, .updated(remote))
        XCTAssertEqual(refreshedDocument, remote)
    }

    func testRefreshRetainsExistingDocumentWhenSignatureIsInvalid() async throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let initial = CatalogDocument(schemaVersion: 2, revision: 1, apps: [])
        let remote = CatalogDocument(schemaVersion: 2, revision: 2, apps: [])
        let encoder = JSONEncoder()
        let documentURL = URL(string: "https://example.invalid/catalog/recommendations.json")!
        let signatureURL = URL(string: "https://example.invalid/catalog/recommendations.sig")!
        let cacheDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        let store = CatalogStore(
            configuration: RecommendationCatalogConfiguration(
                documentURL: documentURL,
                signatureURL: signatureURL,
                publicKeyBase64: privateKey.publicKey.rawRepresentation.base64EncodedString(),
                cacheDirectory: cacheDirectory
            ),
            fetcher: StubCatalogFetcher(
                dataByURL: [
                    documentURL: try encoder.encode(remote),
                    signatureURL: try encoder.encode(CatalogSignature(keyID: "catalog-v2", algorithm: "ed25519", revision: 2, signature: "invalid"))
                ]
            ),
            bundledDocument: initial
        )

        let initialDocument = try await store.loadInitialDocument()
        let refreshResult = await store.refresh()
        let retainedDocument = try await store.loadInitialDocument()

        XCTAssertEqual(initialDocument, initial)
        XCTAssertEqual(refreshResult, .rejected)
        XCTAssertEqual(retainedDocument, initial)
    }
}

private actor StubCatalogFetcher: CatalogDataFetching {
    private let dataByURL: [URL: Data]

    init(dataByURL: [URL: Data]) {
        self.dataByURL = dataByURL
    }

    func data(from url: URL) async throws -> Data {
        guard let data = dataByURL[url] else {
            throw URLError(.fileDoesNotExist)
        }
        return data
    }
}
