//
//  PasswordEntry.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//


import Foundation
import Combine

// A simple model representing a saved password.
struct PasswordEntry: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var password: String
}

class PasswordStore: ObservableObject {
    @Published var passwords: [PasswordEntry] = []
    private let userDefaultsKey = "SavedPasswords"
    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadPasswords()
    }

    /// Loads saved passwords from UserDefaults.
    func loadPasswords() {
        if let data = storage.data(forKey: userDefaultsKey),
           let savedPasswords = try? JSONDecoder().decode([PasswordEntry].self, from: data) {
            self.passwords = savedPasswords
        }
    }

    /// Saves the current list of passwords to UserDefaults.
    func savePasswords() {
        if let data = try? JSONEncoder().encode(passwords) {
            storage.set(data, forKey: userDefaultsKey)
        }
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
}
