//
//  ImportError.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 18/03/2026.
//

import Foundation

enum ImportError: LocalizedError, Identifiable {
    case accessDenied
    case fileUnreadable
    
    var errorDescription: String? {
        switch self {
        case .accessDenied: "Brak dostępu do pliku."
        case .fileUnreadable: "Nie udało się odczytać pliku."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .accessDenied: "Sprawdź uprawnienia aplikacji w ustawieniach."
        case .fileUnreadable: "Upewnij się, że plik nie jest uszkodzony."
        }
    }
    
    var id: Self { self }
}
