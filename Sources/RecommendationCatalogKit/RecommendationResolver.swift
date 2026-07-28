import Foundation

public enum RecommendationResolver {
    public static func resolve(apps: [CatalogApp], input: CatalogInput) -> [ResolvedRecommendation] {
        guard let storefrontCode = normalized(input.storefrontCode) else {
            return []
        }

        var seenAppStoreIDs = Set<String>()

        return apps.compactMap { app in
            guard app.appStoreID != input.currentAppStoreID,
                  app.availableStorefronts.contains(storefrontCode) || app.availableStorefronts.contains("*"),
                  seenAppStoreIDs.insert(app.appStoreID).inserted else {
                return nil
            }

            return ResolvedRecommendation(
                app: app,
                displayTitle: displayTitle(for: app, storefrontCode: storefrontCode, languagePriority: input.languagePriority)
            )
        }
    }

    private static func displayTitle(
        for app: CatalogApp,
        storefrontCode: String,
        languagePriority: [String]
    ) -> String {
        if let storefrontTitle = app.storefrontTitleOverrides?[storefrontCode], !storefrontTitle.isEmpty {
            return storefrontTitle
        }

        for language in languagePriority {
            if let title = app.title[language], !title.isEmpty {
                return title
            }

            let baseLanguage = language.split(separator: "-", maxSplits: 1).first.map(String.init)
            if let baseLanguage, let title = app.title[baseLanguage], !title.isEmpty {
                return title
            }
        }

        return app.title["en"] ?? app.title["zh-Hans"] ?? app.title.values.sorted().first ?? app.id
    }

    private static func normalized(_ storefrontCode: String?) -> String? {
        guard let storefrontCode = storefrontCode?.trimmingCharacters(in: .whitespacesAndNewlines),
              !storefrontCode.isEmpty else {
            return nil
        }
        return storefrontCode.uppercased()
    }
}
