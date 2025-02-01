//
//  RNDecryptorApp.swift
//  RNDecryptor
//
//  Created by Alin Radut on 1/31/25.
//

import SwiftUI

@main
struct RNDecryptorApp: App {
    @StateObject var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
            // Once ContentView appears, pass our appState to the delegate.
                .onAppear {
                    appDelegate.appState = appState
                }
        }
    }
}

