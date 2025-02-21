//
//  PasswordStoreTests.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import XCTest
@testable import RNDecryptor

class PasswordStoreTests: XCTestCase {
    var store: PasswordStore!
    let service = "ro.alinradut.RNDecryptor.TestPasswordStore"

    override func setUp() {
        super.setUp()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        SecItemDelete(query as CFDictionary)

        store = PasswordStore(service: service)
    }

    override func tearDown() {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        SecItemDelete(query as CFDictionary)

        super.tearDown()
    }

    func testAddPassword() {
        store.addPassword(name: "Test", password: "1234")

        XCTAssertEqual(store.passwords.count, 1)
        XCTAssertEqual(store.passwords.first?.name, "Test")
        XCTAssertEqual(store.passwords.first?.password, "1234")
    }

    func testRemovePassword() {
        store.addPassword(name: "Test", password: "1234")
        let id = store.passwords.first!.id

        store.removePassword(with: id)

        XCTAssertEqual(store.passwords.count, 0)
    }

    func testPersistence() {
        store.addPassword(name: "Persistent", password: "secure")

        store.savePasswords()
        store.loadPasswords()

        XCTAssertEqual(store.passwords.count, 1)
        XCTAssertEqual(store.passwords.first?.name, "Persistent")
    }
}
