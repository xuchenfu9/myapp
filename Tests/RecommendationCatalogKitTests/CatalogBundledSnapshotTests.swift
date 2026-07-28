import CryptoKit
import XCTest
@testable import RecommendationCatalogKit

final class CatalogBundledSnapshotTests: XCTestCase {
    func testBundledSnapshotContainsVerifiedCatalogAndIcons() throws {
        let document = try CatalogBundledSnapshot.load()
        let oneDollarID = try XCTUnwrap(document.apps.first { $0.appStoreID == "6758612379" })

        XCTAssertEqual(oneDollarID.availableStorefronts, ["CHN"])
        XCTAssertEqual(oneDollarID.storefrontTitleOverrides?["USA"], "US PassSnap")
        let iconData = try CatalogBundledSnapshot.iconData(for: oneDollarID)
        XCTAssertEqual(SHA256.hash(data: iconData).hexDigest, oneDollarID.icon.sha256)
    }
}

private extension SHA256Digest {
    var hexDigest: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
