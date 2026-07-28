import Foundation

public struct CatalogDocument: Codable, Equatable {
    public let schemaVersion: Int
    public let revision: Int
    public let generatedAt: Date?
    public let apps: [CatalogApp]

    public init(schemaVersion: Int, revision: Int, generatedAt: Date? = nil, apps: [CatalogApp]) {
        self.schemaVersion = schemaVersion
        self.revision = revision
        self.generatedAt = generatedAt
        self.apps = apps
    }
}

public struct CatalogApp: Codable, Identifiable, Equatable {
    public let id: String
    public let appStoreID: String
    public let bundleID: String
    public let storeURL: String
    public let availableStorefronts: [String]
    public let title: [String: String]
    public let storefrontTitleOverrides: [String: String]?
    public let emoji: String
    public let icon: CatalogIcon
    public let upgradePolicy: UpgradePolicy?

    public init(
        id: String,
        appStoreID: String,
        bundleID: String,
        storeURL: String,
        availableStorefronts: [String],
        title: [String: String],
        storefrontTitleOverrides: [String: String]?,
        emoji: String,
        icon: CatalogIcon,
        upgradePolicy: UpgradePolicy?
    ) {
        self.id = id
        self.appStoreID = appStoreID
        self.bundleID = bundleID
        self.storeURL = storeURL
        self.availableStorefronts = availableStorefronts
        self.title = title
        self.storefrontTitleOverrides = storefrontTitleOverrides
        self.emoji = emoji
        self.icon = icon
        self.upgradePolicy = upgradePolicy
    }
}

public struct CatalogIcon: Codable, Equatable {
    public let path: String
    public let sha256: String

    public init(path: String, sha256: String) {
        self.path = path
        self.sha256 = sha256
    }
}

public struct UpgradePolicy: Codable, Equatable {
    public let minimumSupportedVersion: String

    public init(minimumSupportedVersion: String) {
        self.minimumSupportedVersion = minimumSupportedVersion
    }
}

public struct CatalogInput: Equatable {
    public let currentAppStoreID: String
    public let storefrontCode: String?
    public let languagePriority: [String]

    public init(currentAppStoreID: String, storefrontCode: String?, languagePriority: [String]) {
        self.currentAppStoreID = currentAppStoreID
        self.storefrontCode = storefrontCode
        self.languagePriority = languagePriority
    }
}

public struct ResolvedRecommendation: Identifiable, Equatable {
    public let app: CatalogApp
    public let displayTitle: String

    public var id: String { app.appStoreID }
    public var appStoreID: String { app.appStoreID }
    public var storeURL: String { app.storeURL }
    public var emoji: String { app.emoji }

    public init(app: CatalogApp, displayTitle: String) {
        self.app = app
        self.displayTitle = displayTitle
    }
}
