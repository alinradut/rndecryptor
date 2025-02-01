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

    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "TestPasswordStore")!
        testDefaults.removePersistentDomain(forName: "TestPasswordStore") // Clear stored data
        store = PasswordStore(storage: testDefaults)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: "TestPasswordStore")
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
