import Foundation
import XCTest
@testable import RecommendationCatalogKit

final class PublishedCatalogArtifactTests: XCTestCase {
    func testPublishedCatalogArtifactVerifiesWithEmbeddedPublicKey() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let catalogDirectory = packageRoot.appendingPathComponent("catalog", isDirectory: true)
        let documentData = try Data(contentsOf: catalogDirectory.appendingPathComponent("recommendations.json"))
        let signatureData = try Data(contentsOf: catalogDirectory.appendingPathComponent("recommendations.sig"))
        let signature = try JSONDecoder().decode(CatalogSignature.self, from: signatureData)

        XCTAssertNoThrow(
            try CatalogSignatureVerifier.verify(
                documentData: documentData,
                signature: signature,
                publicKeyBase64: CatalogPublicKey.catalogV2Base64
            )
        )
    }
}
