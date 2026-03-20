//
//  DocumentExtractor.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 18/03/2026.
//

import Foundation

protocol DocumentExtractor {
    func extract(from file: ImportedFile) async throws -> ExtractedDocument
}
