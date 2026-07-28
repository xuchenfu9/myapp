import CryptoKit
import XCTest
@testable import RecommendationCatalogKit

final class CatalogSignatureVerifierTests: XCTestCase {
    func testAcceptsSignatureForExactDocumentBytesAndMatchingRevision() throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let documentData = Data(#"{"schemaVersion":2,"revision":7,"apps":[]}"#.utf8)
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 7,
            signature: try privateKey.signature(for: documentData).base64EncodedString()
        )

        XCTAssertNoThrow(
            try CatalogSignatureVerifier.verify(
                documentData: documentData,
                signature: signature,
                publicKeyBase64: privateKey.publicKey.rawRepresentation.base64EncodedString()
            )
        )
    }

    func testRejectsSignatureWhoseRevisionDoesNotMatchDocument() throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let documentData = Data(#"{"schemaVersion":2,"revision":7,"apps":[]}"#.utf8)
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 8,
            signature: try privateKey.signature(for: documentData).base64EncodedString()
        )

        XCTAssertThrowsError(
            try CatalogSignatureVerifier.verify(
                documentData: documentData,
                signature: signature,
                publicKeyBase64: privateKey.publicKey.rawRepresentation.base64EncodedString()
            )
        ) { error in
            XCTAssertEqual(error as? CatalogSignatureVerificationError, .revisionMismatch)
        }
    }
}
