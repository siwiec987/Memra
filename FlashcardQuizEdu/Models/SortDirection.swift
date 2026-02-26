//
//  SortDirection.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 24/02/2026.
//

import Foundation

enum SortDirection: Int, CaseIterable, Identifiable {
    case ascending = 0
    case descending
    
    var id: Int { rawValue }
}
