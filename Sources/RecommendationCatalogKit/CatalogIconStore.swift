import CryptoKit
import Foundation

public actor CatalogIconStore {
    private let baseURL: URL
    private let cacheDirectory: URL
    private let fetcher: any CatalogDataFetching
    private let fileManager: FileManager

    public init(
        baseURL: URL,
        cacheDirectory: URL,
        fetcher: any CatalogDataFetching = URLSessionCatalogDataFetcher(),
        fileManager: FileManager = .default
    ) {
        self.baseURL = baseURL
        self.cacheDirectory = cacheDirectory
        self.fetcher = fetcher
        self.fileManager = fileManager
    }

    public func iconData(for app: CatalogApp) async -> Data? {
        if let cachedData = try? Data(contentsOf: cacheURL(for: app)), matchesDigest(cachedData, app: app) {
            return cachedData
        }

        if let bundledData = try? CatalogBundledSnapshot.iconData(for: app), matchesDigest(bundledData, app: app) {
            return bundledData
        }

        do {
            let downloadedData = try await fetcher.data(from: baseURL.appendingPathComponent(app.icon.path))
            guard matchesDigest(downloadedData, app: app) else {
                return nil
            }

            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            try downloadedData.write(to: cacheURL(for: app), options: .atomic)
            return downloadedData
        } catch {
            return nil
        }
    }

    private func cacheURL(for app: CatalogApp) -> URL {
        cacheDirectory.appendingPathComponent(URL(fileURLWithPath: app.icon.path).lastPathComponent)
    }

    private func matchesDigest(_ data: Data, app: CatalogApp) -> Bool {
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        return digest == app.icon.sha256.lowercased()
    }
}
