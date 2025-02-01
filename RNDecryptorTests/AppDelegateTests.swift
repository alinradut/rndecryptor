//
//  AppDelegateTests.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import XCTest
@testable import RNDecryptor

class AppDelegateTests: XCTestCase {
    func testOpenFile() {
        let appDelegate = AppDelegate()
        let appState = AppState()
        appDelegate.appState = appState

        let filePath = "/test/path.txt"
        let result = appDelegate.application(NSApplication.shared, openFile: filePath)

        XCTAssertTrue(result)

        let expectation = XCTestExpectation(description: "openedFilePath should be updated asynchronously")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(appState.openedFilePath, filePath)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testOpenURL() {
        let appDelegate = AppDelegate()
        let appState = AppState()
        appDelegate.appState = appState

        let url = URL(fileURLWithPath: "/test/url/path.txt")
        appDelegate.application(NSApplication.shared, open: [url])

        let expectation = XCTestExpectation(description: "openedFilePath should be updated asynchronously")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(appState.openedFilePath, "/test/url/path.txt")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
