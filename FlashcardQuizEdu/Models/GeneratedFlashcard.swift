//
//  GeneratedFlashcard.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedFlashcard {
    @Guide(description: "A specific study question based only on the provided source text.")
    let question: String

    @Guide(description: "A concise factual answer supported directly by the provided source text.")
    let answer: String
}
