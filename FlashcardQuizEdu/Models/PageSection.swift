//
//  PageSection.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/03/2026.
//

import Foundation

enum PageSection: Sendable {
    case paragraph(String)
    case list([String])
    case table([[String]])

    var markdownText: String {
        switch self {
        case .paragraph(let text):
            return text

        case .list(let items):
            return "LIST:{\n" + items
                .map { "- \($0)" }
                .joined(separator: "\n") + "}"

        case .table(let rows):
            return "TABLE:{\n" + rows
                .map { $0.joined(separator: " | ") }
                .joined(separator: "\n") + "}"
        }
    }

    var plainText: String {
        switch self {
        case .paragraph(let text):
            return text

        case .list(let items):
            return items.joined(separator: "\n")

        case .table(let rows):
            return rows
                .map { $0.joined(separator: " | ") }
                .joined(separator: "\n")
        }
    }
}
