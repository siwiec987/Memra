//
//  ExtractError.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/03/2026.
//


import Foundation

enum ExtractError: LocalizedError {
    case fileUnreadable
    case fileEmpty

    var errorDescription: String? {
        switch self {
        case .fileUnreadable:
            "Nie udało się odczytać zawartości pliku."
        case .fileEmpty:
            "Nie znaleziono tekstu do wyodrębnienia."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileUnreadable:
            "Upewnij się, że plik nie jest uszkodzony i spróbuj ponownie."
        case .fileEmpty:
            "Wybierz plik lub zdjęcie zawierające czytelny tekst."
        }
    }
}
