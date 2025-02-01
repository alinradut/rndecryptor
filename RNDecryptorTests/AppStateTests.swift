//
//  AppStateTests.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import XCTest
@testable import RNDecryptor

class AppStateTests: XCTestCase {
    func testOpenedFilePathChange() {
        let appState = AppState()
        let expectation = XCTestExpectation(description: "openedFilePath should change")

        let cancellable = appState.$openedFilePath.sink { newValue in
            if newValue == "/test/path.txt" {
                expectation.fulfill()
            }
        }

        appState.openedFilePath = "/test/path.txt"
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
}
