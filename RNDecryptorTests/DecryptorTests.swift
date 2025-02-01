//
//  DecryptorTests.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//


import XCTest
import RNCryptor
@testable import RNDecryptor

class DecryptorTests: XCTestCase {
    func testDecryptString() {
        let password = "testpassword"
        let originalString = "Hello, World!"

        // Encrypt data using RNCryptor
        let encryptedData = RNCryptor.Encryptor(password: password).encrypt(data: originalString.data(using: .utf8)!)
        let encryptedString = encryptedData.base64EncodedString()

        // Decrypt using our `Decryptor` class
        do {
            let decrypted = try Decryptor.decryptString(encryptedString, password: password)
            XCTAssertEqual(decrypted, originalString)
        } catch {
            XCTFail("Decryption failed with error: \(error)")
        }
    }

    func testDecryptFileData() throws {
        let password = "filetest"
        let originalData = "File Content Test".data(using: .utf8)!

        // Encrypt file data
        let encryptedData = RNCryptor.Encryptor(password: password).encrypt(data: originalData)

        // Write to temp file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.enc")
        try encryptedData.write(to: tempURL)

        // Decrypt
        let decryptedData = try Decryptor.decryptFileData(at: tempURL.path, with: password)

        XCTAssertEqual(decryptedData, originalData)
    }
}
