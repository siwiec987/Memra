//
//  DocumentChunkingError.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation

enum DocumentChunkingError: LocalizedError {
    case lineChunkTooLarge

    var errorDescription: String? {
        switch self {
        case .lineChunkTooLarge:
            "Nie udało się podzielić tekstu na fragmenty mieszczące się w limicie modelu."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .lineChunkTooLarge:
            "Spróbuj ponownie z krótszym materiałem."
        }
    }
}
