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
    
    var pageCount: Int {
        pages.count
    }
    
    var markdownText: String {
        pages
            .map(\.markdownText)
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
            .trimmed()
    }
    
    func markdownText(pageLimit: Int, offset: Int = 0) -> String {
        pages.dropFirst(offset).prefix(pageLimit)
            .map(\.markdownText)
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
}

extension ExtractedDocument {
    init(sourceFileID: UUID, pages: [ExtractedPage]) {
        self.id = UUID()
        self.sourceFileID = sourceFileID
        self.pages = pages
    }
}
