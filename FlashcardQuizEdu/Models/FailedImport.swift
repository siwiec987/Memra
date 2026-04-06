//
//  FailedImport.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 03/04/2026.
//

import Foundation

struct FailedImport: Equatable, Identifiable {
        let id = UUID()
        let fileName: String
        let error: Error
        
        static func == (lhs: FailedImport, rhs: FailedImport) -> Bool {
            lhs.id == rhs.id
        }
    }
