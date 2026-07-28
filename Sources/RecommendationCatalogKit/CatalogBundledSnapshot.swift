import Foundation

public enum CatalogBundledSnapshot {
    public static func load() throws -> CatalogDocument {
        guard let url = Bundle.module.url(
            forResource: "recommendations",
            withExtension: "json"
        ) else {
            throw CatalogBundledSnapshotError.missingDocument
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CatalogDocument.self, from: Data(contentsOf: url))
    }

    public static func iconData(for app: CatalogApp) throws -> Data {
        let iconURL = URL(fileURLWithPath: app.icon.path)
        guard let url = Bundle.module.url(
            forResource: iconURL.deletingPathExtension().lastPathComponent,
            withExtension: iconURL.pathExtension
        ) else {
            throw CatalogBundledSnapshotError.missingIcon(app.icon.path)
        }

        return try Data(contentsOf: url)
    }
}

public enum CatalogBundledSnapshotError: Error, Equatable {
    case missingDocument
    case missingIcon(String)
}
