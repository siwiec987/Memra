//
//  ExtractedDocument.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 18/03/2026.
//

import Foundation

struct ExtractedDocument: Identifiable, Sendable {
    let id: UUID
    let sourceFileID: UUID
    let pages: [ExtractedPage]
    
    var markdownText: String {
        pages
            .map(\.markdownText)
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n---\n\n")
    }
}

extension ExtractedDocument {
    init(sourceFileID: UUID, pages: [ExtractedPage]) {
        self.id = UUID()
        self.sourceFileID = sourceFileID
        self.pages = pages
    }
}
