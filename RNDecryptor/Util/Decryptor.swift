//
//  Decryptor.swift
//  RNDecryptor
//
//  Created by Alin Radut on 1/31/25.
//
import Foundation
import RNCryptor

enum Decryptor {
    
    /// Decrypt an encrypted string (base64 or raw data) using a password.
    /// - Parameters:
    ///   - encryptedString: The string to decrypt. Should be the result of an RNCryptor encryption (often Base64).
    ///   - password: The password used for encryption.
    /// - Returns: A plaintext string if successful, otherwise throws.
    static func decryptString(_ encryptedString: String, password: String) throws -> String {
        
        // If your encryptedString is base64-encoded, decode it:
        guard let encryptedData = Data(base64Encoded: encryptedString) ?? encryptedString.data(using: .utf8)
        else {
            throw NSError(domain: "Decryptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid string encoding"])
        }

        // Decrypt using RNCryptor
        let decryptor = RNCryptor.Decryptor(password: password)
        let decryptedData = try decryptor.decrypt(data: encryptedData)

        // Convert data back to string
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "Decryptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert decrypted data to string"])
        }
        
        return decryptedString
    }
    
    /// Decrypt a file at a given path using a password. Writes the decrypted content to a new file.
    /// - Parameters:
    ///   - filePath: Full path to the encrypted file.
    ///   - password: The password used for encryption.
    /// - Returns: The output file path where the decrypted contents are stored.
    static func decryptFileData(at filePath: String, with password: String) throws -> Data {

        // Read the encrypted file data
        let fileURL = URL(fileURLWithPath: filePath)
        let encryptedData = try Data(contentsOf: fileURL)
        
        // Decrypt
        let decryptor = RNCryptor.Decryptor(password: password)
        let decryptedData = try decryptor.decrypt(data: encryptedData)

        return decryptedData
    }
}
