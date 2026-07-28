import XCTest
@testable import RecommendationCatalogKit

final class UpgradeGateTests: XCTestCase {
    func testRequiresUpgradeWhenCurrentVersionIsBelowCatalogMinimum() {
        let document = CatalogDocument(
            schemaVersion: 2,
            revision: 1,
            apps: [
                makeApp(appStoreID: "current", minimumSupportedVersion: "1.10.0"),
                makeApp(appStoreID: "other", minimumSupportedVersion: "99.0.0")
            ]
        )

        XCTAssertEqual(
            UpgradeGate.decision(
                document: document,
                currentAppStoreID: "current",
                currentVersion: "1.9.9"
            ),
            .required(minimumSupportedVersion: "1.10.0")
        )
    }

    func testAllowsEqualOrHigherVersionAndMissingPolicy() {
        let document = CatalogDocument(
            schemaVersion: 2,
            revision: 1,
            apps: [
                makeApp(appStoreID: "equal", minimumSupportedVersion: "1.10"),
                makeApp(appStoreID: "none", minimumSupportedVersion: nil)
            ]
        )

        XCTAssertEqual(
            UpgradeGate.decision(
                document: document,
                currentAppStoreID: "equal",
                currentVersion: "1.10.0"
            ),
            .allowed
        )
        XCTAssertEqual(
            UpgradeGate.decision(
                document: document,
                currentAppStoreID: "none",
                currentVersion: "0.1"
            ),
            .allowed
        )
    }

    private func makeApp(appStoreID: String, minimumSupportedVersion: String?) -> CatalogApp {
        CatalogApp(
            id: appStoreID,
            appStoreID: appStoreID,
            bundleID: "com.example.\(appStoreID)",
            storeURL: "https://apps.apple.com/app/id\(appStoreID)",
            availableStorefronts: ["USA"],
            title: ["en": appStoreID],
            storefrontTitleOverrides: nil,
            emoji: "*",
            icon: CatalogIcon(path: "icons/\(appStoreID).png", sha256: "hash"),
            upgradePolicy: minimumSupportedVersion.map(UpgradePolicy.init)
        )
    }
}
