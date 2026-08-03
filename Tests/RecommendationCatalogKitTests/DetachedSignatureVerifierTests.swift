import CryptoKit
import XCTest
@testable import RecommendationCatalogKit

final class DetachedSignatureVerifierTests: XCTestCase {
    func testAcceptsSignatureForExactSignedJSONBytes() throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let documentData = Data(#"{"tips":[{"title":"Take a break"}]}"#.utf8)
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 0,
            signature: try privateKey.signature(for: documentData).base64EncodedString()
        )

        XCTAssertNoThrow(
            try DetachedSignatureVerifier.verify(
                documentData: documentData,
                signature: signature,
                publicKeyBase64: privateKey.publicKey.rawRepresentation.base64EncodedString()
            )
        )
    }

    func testRejectsModifiedDocumentBytes() throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let signedData = Data(#"{"tips":[{"title":"Take a break"}]}"#.utf8)
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 0,
            signature: try privateKey.signature(for: signedData).base64EncodedString()
        )

        XCTAssertThrowsError(
            try DetachedSignatureVerifier.verify(
                documentData: Data(#"{"tips":[{"title":"Skip a break"}]}"#.utf8),
                signature: signature,
                publicKeyBase64: privateKey.publicKey.rawRepresentation.base64EncodedString()
            )
        ) { error in
            XCTAssertEqual(error as? CatalogSignatureVerificationError, .invalidSignature)
        }
    }

    func testRejectsSignatureWithWrongPublicKey() throws {
        let signingKey = Curve25519.Signing.PrivateKey()
        let wrongKey = Curve25519.Signing.PrivateKey()
        let documentData = Data(#"{"tips":[{"title":"Take a break"}]}"#.utf8)
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 0,
            signature: try signingKey.signature(for: documentData).base64EncodedString()
        )

        XCTAssertThrowsError(
            try DetachedSignatureVerifier.verify(
                documentData: documentData,
                signature: signature,
                publicKeyBase64: wrongKey.publicKey.rawRepresentation.base64EncodedString()
            )
        ) { error in
            XCTAssertEqual(error as? CatalogSignatureVerificationError, .invalidSignature)
        }
    }

    func testRejectsUnsupportedKeyID() {
        let signature = CatalogSignature(
            keyID: "tips-v1",
            algorithm: "ed25519",
            revision: 0,
            signature: "ignored"
        )

        XCTAssertThrowsError(
            try DetachedSignatureVerifier.verify(
                documentData: Data(#"{"tips":[]}"#.utf8),
                signature: signature,
                publicKeyBase64: "ignored"
            )
        ) { error in
            XCTAssertEqual(error as? CatalogSignatureVerificationError, .unsupportedSignature)
        }
    }

    func testRejectsInvalidSignatureBase64() {
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 0,
            signature: "not base64"
        )

        XCTAssertThrowsError(
            try DetachedSignatureVerifier.verify(
                documentData: Data(#"{"tips":[]}"#.utf8),
                signature: signature,
                publicKeyBase64: "AA=="
            )
        ) { error in
            XCTAssertEqual(error as? CatalogSignatureVerificationError, .invalidSignatureEncoding)
        }
    }

    func testRejectsInvalidPublicKeyBase64() {
        let signature = CatalogSignature(
            keyID: "catalog-v2",
            algorithm: "ed25519",
            revision: 0,
            signature: "AA=="
        )

        XCTAssertThrowsError(
            try DetachedSignatureVerifier.verify(
                documentData: Data(#"{"tips":[]}"#.utf8),
                signature: signature,
                publicKeyBase64: "not base64"
            )
        ) { error in
            XCTAssertEqual(error as? CatalogSignatureVerificationError, .invalidPublicKey)
        }
    }
}
