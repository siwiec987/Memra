//
//  AIProcessingError.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation

enum AIProcessingError: LocalizedError {
    case chunkTooLarge

    var errorDescription: String? {
        switch self {
        case .chunkTooLarge:
            "Nie udało się przetworzyć tekstu, ponieważ fragment był zbyt duży dla modelu."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .chunkTooLarge:
            "Spróbuj ponownie z krótszym materiałem albo podziel tekst na mniejsze części."
        }
    }
}
