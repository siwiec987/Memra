//
//  EditStudySetError.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/03/2026.
//

import Foundation

enum EditStudySetError: LocalizedError {
    case studySetNotFound
    
    var errorDescription: String? {
        switch self {
        case .studySetNotFound:
            "Nie udało się otworzyć zestawu."
        }
    }
}
