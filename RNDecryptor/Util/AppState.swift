//
//  AppState.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var openedFilePath: String = ""
}
