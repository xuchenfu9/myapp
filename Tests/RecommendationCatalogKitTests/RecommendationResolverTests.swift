import XCTest
@testable import RecommendationCatalogKit

final class RecommendationResolverTests: XCTestCase {
    func testStorefrontTitleOverrideTakesPrecedenceOverLanguageTitle() {
        let app = CatalogApp(
            id: "one-dollar-id",
            appStoreID: "6758612379",
            bundleID: "com.pans.jiajia-photoid",
            storeURL: "https://apps.apple.com/app/id6758612379",
            availableStorefronts: ["CHN", "USA"],
            title: ["zh-Hans": "佳佳证件照", "en": "ID Photo"],
            storefrontTitleOverrides: ["CHN": "证照准拍", "USA": "US PassSnap"],
            emoji: "*",
            icon: CatalogIcon(path: "icons/6758612379.png", sha256: "hash"),
            upgradePolicy: nil
        )

        let result = RecommendationResolver.resolve(
            apps: [app],
            input: CatalogInput(
                currentAppStoreID: "another-app",
                storefrontCode: "USA",
                languagePriority: ["zh-Hans"]
            )
        )

        XCTAssertEqual(result.map(\.displayTitle), ["US PassSnap"])
    }

    func testResolverFiltersSelfAndRequiresAKnownStorefront() {
        let apps = [
            makeApp(appStoreID: "current", storefronts: ["USA"]),
            makeApp(appStoreID: "visible", storefronts: ["USA"]),
            makeApp(appStoreID: "hidden", storefronts: ["CHN"])
        ]

        XCTAssertEqual(
            RecommendationResolver.resolve(
                apps: apps,
                input: CatalogInput(
                    currentAppStoreID: "current",
                    storefrontCode: "USA",
                    languagePriority: ["en"]
                )
            ).map(\.appStoreID),
            ["visible"]
        )

        XCTAssertTrue(
            RecommendationResolver.resolve(
                apps: apps,
                input: CatalogInput(
                    currentAppStoreID: "current",
                    storefrontCode: nil,
                    languagePriority: ["en"]
                )
            ).isEmpty
        )
    }

    private func makeApp(appStoreID: String, storefronts: [String]) -> CatalogApp {
        CatalogApp(
            id: appStoreID,
            appStoreID: appStoreID,
            bundleID: "com.example.\(appStoreID)",
            storeURL: "https://apps.apple.com/app/id\(appStoreID)",
            availableStorefronts: storefronts,
            title: ["en": appStoreID],
            storefrontTitleOverrides: nil,
            emoji: "*",
            icon: CatalogIcon(path: "icons/\(appStoreID).png", sha256: "hash"),
            upgradePolicy: nil
        )
    }
}
