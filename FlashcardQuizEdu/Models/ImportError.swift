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
    case unsupportedContentType
    case imageDecodingFailed
    
    var errorDescription: String? {
        switch self {
        case .accessDenied: "Brak dostępu do pliku."
        case .fileUnreadable: "Nie udało się odczytać pliku."
        case .unsupportedContentType: "Nieobsługiwany typ pliku."
        case .imageDecodingFailed: "Nie udało się otworzyć obrazu."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .accessDenied: "Spróbuj ponownie wybrać plik i upewnij się, że aplikacja ma do niego dostęp."
        case .fileUnreadable: "Upewnij się, że plik nie jest uszkodzony."
        case .unsupportedContentType: "Wybierz plik lub zdjęcie w obsługiwanym formacie."
        case .imageDecodingFailed: "Wybierz inne zdjęcie lub spróbuj ponownie z innym formatem."
        }
    }
    
    var id: Self { self }
}
