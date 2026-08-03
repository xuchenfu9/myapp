import Foundation
import XCTest
@testable import RecommendationCatalogKit

final class PublishedSecretaryTipsArtifactTests: XCTestCase {
    func testPublishedSecretaryTipsArtifactVerifiesWithEmbeddedPublicKey() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let catalogDirectory = packageRoot.appendingPathComponent("catalog", isDirectory: true)
        let documentData = try Data(contentsOf: catalogDirectory.appendingPathComponent("banzhuren/secretary-tips.json"))
        let signatureData = try Data(contentsOf: catalogDirectory.appendingPathComponent("banzhuren/secretary-tips.sig"))
        let signature = try JSONDecoder().decode(CatalogSignature.self, from: signatureData)
        let document = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: documentData) as? [String: Any]
        )

        XCTAssertEqual(document["revision"] as? Int, signature.revision)
        try DetachedSignatureVerifier.verify(
            documentData: documentData,
            signature: signature,
            publicKeyBase64: CatalogPublicKey.catalogV2Base64
        )
    }
}
