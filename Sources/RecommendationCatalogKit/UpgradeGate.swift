import Foundation

public enum UpgradeDecision: Equatable {
    case allowed
    case required(minimumSupportedVersion: String)
}

public enum UpgradeGate {
    public static func decision(
        document: CatalogDocument,
        currentAppStoreID: String,
        currentVersion: String
    ) -> UpgradeDecision {
        guard let minimumSupportedVersion = document.apps.first(where: { $0.appStoreID == currentAppStoreID })?
            .upgradePolicy?
            .minimumSupportedVersion,
            compare(currentVersion, to: minimumSupportedVersion) == .orderedAscending else {
            return .allowed
        }

        return .required(minimumSupportedVersion: minimumSupportedVersion)
    }

    private static func compare(_ left: String, to right: String) -> ComparisonResult {
        let leftComponents = versionComponents(left)
        let rightComponents = versionComponents(right)
        let count = max(leftComponents.count, rightComponents.count)

        for index in 0..<count {
            let leftValue = index < leftComponents.count ? leftComponents[index] : 0
            let rightValue = index < rightComponents.count ? rightComponents[index] : 0

            if leftValue < rightValue { return .orderedAscending }
            if leftValue > rightValue { return .orderedDescending }
        }

        return .orderedSame
    }

    private static func versionComponents(_ version: String) -> [Int] {
        version.split(separator: ".", omittingEmptySubsequences: false).map { Int($0) ?? 0 }
    }
}
