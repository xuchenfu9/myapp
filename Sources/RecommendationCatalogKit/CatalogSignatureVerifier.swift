import CryptoKit
import Foundation

public struct CatalogSignature: Codable, Equatable {
    public let keyID: String
    public let algorithm: String
    public let revision: Int
    public let signature: String

    public init(keyID: String, algorithm: String, revision: Int, signature: String) {
        self.keyID = keyID
        self.algorithm = algorithm
        self.revision = revision
        self.signature = signature
    }
}

public enum CatalogSignatureVerifier {
    public static func verify(
        documentData: Data,
        signature: CatalogSignature,
        publicKeyBase64: String
    ) throws {
        guard signature.keyID == "catalog-v2", signature.algorithm == "ed25519" else {
            throw CatalogSignatureVerificationError.unsupportedSignature
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let document = try? decoder.decode(CatalogDocument.self, from: documentData) else {
            throw CatalogSignatureVerificationError.invalidDocument
        }
        guard document.revision == signature.revision else {
            throw CatalogSignatureVerificationError.revisionMismatch
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

public enum CatalogSignatureVerificationError: Error, Equatable {
    case unsupportedSignature
    case invalidDocument
    case revisionMismatch
    case invalidPublicKey
    case invalidSignatureEncoding
    case invalidSignature
}
