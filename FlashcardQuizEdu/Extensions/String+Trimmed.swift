//
//  String+Trimmed.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 06/03/2026.
//

import Foundation

extension String {
    func trimmed() -> Self {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
