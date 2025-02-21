//
//  PasswordEntry.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//


import Foundation
import Combine
import Security

// A simple model representing a saved password.
struct PasswordEntry: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var password: String
}

class PasswordStore: ObservableObject {
    @Published var passwords: [PasswordEntry] = []
    private let service: String

    init(service: String = "ro.alinradut.RNDecryptor") {
        self.service = service
        loadPasswords()
    }

    /// Loads saved passwords from the Keychain.
    func loadPasswords() {
        passwords = retrievePasswords() ?? []
    }

    /// Saves the current list of passwords to the Keychain.
    func savePasswords() {
        storePasswords(passwords)
    }

    /// Adds a new password entry.
    func addPassword(name: String, password: String) {
        let newEntry = PasswordEntry(name: name, password: password)
        passwords.append(newEntry)
        savePasswords()
    }

    /// Removes a password by its identifier.
    func removePassword(with id: UUID) {
        if let index = passwords.firstIndex(where: { $0.id == id }) {
            passwords.remove(at: index)
            savePasswords()
        }
    }

    private func storePasswords(_ passwords: [PasswordEntry]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(passwords) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecValueData as String: data
            ]

            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    private func retrievePasswords() -> [PasswordEntry]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode([PasswordEntry].self, from: data)
        }
        return nil
    }
}
