//
//  GeneratedFlashcard.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedFlashcard: Hashable {
    @Guide(description: "A specific study question that can be answered using only the provided source text. Do not use outside knowledge.")
    let question: String

    @Guide(description: "A concise factual answer (1–3 sentences) taken directly from the provided source text. Do not infer or add information.")
    let answer: String
}
