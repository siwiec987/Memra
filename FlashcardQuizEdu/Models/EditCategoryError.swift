//
//  EditCategoryError.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/03/2026.
//

import Foundation

enum EditCategoryError: LocalizedError {
    case categoryNotFound

    var errorDescription: String? {
        switch self {
        case .categoryNotFound:
            "Nie udało się otworzyć kategorii."
        }
    }
}
