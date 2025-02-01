//
//  AppDelegate.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    // This property will be set from our main App struct.
    var appState: AppState?

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        DispatchQueue.main.async {
            self.appState?.openedFilePath = filename
        }
        return true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let path = urls.first?.path else {
            return
        }
        DispatchQueue.main.async {
            self.appState?.openedFilePath = path
        }
    }
}
