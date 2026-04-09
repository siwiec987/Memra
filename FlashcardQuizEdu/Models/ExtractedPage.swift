//
//  ExtractedPage.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/03/2026.
//

import Foundation
import FoundationModels

struct ExtractedPage: Sendable {
    let title: String?
    let sections: [PageSection]

    var markdownText: String {
        var parts: [String] = []

        if let title, !title.isEmpty {
            parts.append("# \(title)")
        }

        for section in sections {
            let content = section.markdownText
            guard !content.isEmpty else { continue }
            parts.append(content)
        }

        return parts.joined(separator: "\n\n")
    }

    var plainText: String {
        sections
            .map(\.plainText)
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
}

extension ExtractedPage {
    init(sections: [PageSection]) {
        self.title = nil
        self.sections = sections
    }
}
