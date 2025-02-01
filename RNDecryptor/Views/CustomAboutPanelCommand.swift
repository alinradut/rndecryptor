//
//  CustomAboutPanelCommand.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import SwiftUI
import AppKit

struct CustomAboutPanelCommand: Commands {
    var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.appInfo) {
            Button("About RNDecryptor") {

                let options: [NSApplication.AboutPanelOptionKey: Any] = [
                    .credits: aboutString,
                ]

                NSApplication.shared.orderFrontStandardAboutPanel(options: options)
            }
        }
    }

    private var aboutString: NSAttributedString {

        // The plain text.
        let text = """
RNDecryptor is an open source project.

More information is available at

https://github.com/alinradut/rndecryptor
"""

        // Create a mutable attributed string from the text.
        let mutableAttributedString = NSMutableAttributedString(string: text)

        // Create a paragraph style that center aligns the text.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Apply the paragraph style to the entire string.
        mutableAttributedString.addAttribute(.paragraphStyle,
                                             value: paragraphStyle,
                                             range: NSRange(location: 0, length: mutableAttributedString.length))

        // Find the range of the GitHub URL in the text.
        if let linkRange = text.range(of: "https://github.com/alinradut/rndecryptor") {
            let nsRange = NSRange(linkRange, in: text)
            // Add the link attribute with the URL. (This makes the text clickable.)
            mutableAttributedString.addAttribute(.link,
                                                 value: URL(string: "https://github.com/alinradut/rndecryptor")!,
                                                 range: nsRange)

            // Optionally, you can also set the link text color and underline style.
            mutableAttributedString.addAttribute(.foregroundColor,
                                                 value: NSColor.systemBlue,
                                                 range: nsRange)
            mutableAttributedString.addAttribute(.underlineStyle,
                                                 value: NSUnderlineStyle.single.rawValue,
                                                 range: nsRange)
        }

        return mutableAttributedString
    }
}
