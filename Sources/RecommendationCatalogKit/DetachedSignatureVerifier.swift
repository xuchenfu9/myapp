import CryptoKit
import Foundation

public enum DetachedSignatureVerifier {
    /// Verifies the supported signature metadata, public key, and signature over the exact document bytes.
    ///
    /// This method does not decode `documentData` or validate `signature.revision`.
    /// Callers must decode the document and compare its revision with `signature.revision` separately.
    public static func verify(
        documentData: Data,
        signature: CatalogSignature,
        publicKeyBase64: String
    ) throws {
        guard signature.keyID == "catalog-v2", signature.algorithm == "ed25519" else {
            throw CatalogSignatureVerificationError.unsupportedSignature
        }
        guard let publicKeyData = Data(base64Encoded: publicKeyBase64) else {
            throw CatalogSignatureVerificationError.invalidPublicKey
        }
        guard let signatureData = Data(base64Encoded: signature.signature) else {
            throw CatalogSignatureVerificationError.invalidSignatureEncoding
        }

        let publicKey: Curve25519.Signing.PublicKey
        do {
            publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: publicKeyData)
        } catch {
            throw CatalogSignatureVerificationError.invalidPublicKey
        }

        guard publicKey.isValidSignature(signatureData, for: documentData) else {
            throw CatalogSignatureVerificationError.invalidSignature
        }
    }
}
