import CryptoKit
import XCTest
@testable import RecommendationCatalogKit

final class CatalogIconStoreTests: XCTestCase {
    func testDownloadsAndCachesIconOnlyWhenDigestMatches() async throws {
        let iconData = Data("verified icon".utf8)
        let app = CatalogApp(
            id: "new-app",
            appStoreID: "123",
            bundleID: "com.example.new-app",
            storeURL: "https://apps.apple.com/app/id123",
            availableStorefronts: ["USA"],
            title: ["en": "New App"],
            storefrontTitleOverrides: nil,
            emoji: "*",
            icon: CatalogIcon(path: "icons/123.png", sha256: SHA256.hash(data: iconData).hexDigest),
            upgradePolicy: nil
        )
        let cacheDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }
        let baseURL = URL(string: "https://example.invalid/catalog/")!
        let remoteURL = baseURL.appendingPathComponent(app.icon.path)
        let store = CatalogIconStore(
            baseURL: baseURL,
            cacheDirectory: cacheDirectory,
            fetcher: StubIconFetcher(dataByURL: [remoteURL: iconData])
        )

        let returnedIconData = await store.iconData(for: app)
        XCTAssertEqual(returnedIconData, iconData)
        XCTAssertEqual(
            try Data(contentsOf: cacheDirectory.appendingPathComponent("123.png")),
            iconData
        )
    }

    func testRejectsIconWhoseDigestDoesNotMatch() async {
        let app = CatalogApp(
            id: "new-app",
            appStoreID: "123",
            bundleID: "com.example.new-app",
            storeURL: "https://apps.apple.com/app/id123",
            availableStorefronts: ["USA"],
            title: ["en": "New App"],
            storefrontTitleOverrides: nil,
            emoji: "*",
            icon: CatalogIcon(path: "icons/123.png", sha256: "not-a-real-digest"),
            upgradePolicy: nil
        )
        let cacheDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }
        let baseURL = URL(string: "https://example.invalid/catalog/")!
        let remoteURL = baseURL.appendingPathComponent(app.icon.path)
        let store = CatalogIconStore(
            baseURL: baseURL,
            cacheDirectory: cacheDirectory,
            fetcher: StubIconFetcher(dataByURL: [remoteURL: Data("untrusted".utf8)])
        )

        let returnedIconData = await store.iconData(for: app)
        XCTAssertNil(returnedIconData)
    }
}

private actor StubIconFetcher: CatalogDataFetching {
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

private extension SHA256Digest {
    var hexDigest: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
