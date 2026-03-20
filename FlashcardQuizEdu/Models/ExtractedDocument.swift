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
    let rawText: String
    let chunks: [String]
}

extension ExtractedDocument {
    init(sourceFileID: UUID, rawText: String, chunks: [String]) {
        self.id = UUID()
        self.sourceFileID = sourceFileID
        self.rawText = rawText
        self.chunks = []
    }
}
