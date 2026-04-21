//
//  GeneratedStudySet.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedStudySet: Hashable {
    let name: String
//    let category: CategoryEntity //???
    let flashcards: [Flashcard]
    let quiz: [QuizQuestion]
//    let tags: [TagEntity] //???
    
    @Generable
    struct Flashcard: Hashable {
        @Guide(description: "A specific study question that can be answered using only the provided source text. Do not use outside knowledge.")
        let question: String
        
        @Guide(description: "A concise factual answer (1–3 sentences) taken directly from the provided source text. Do not infer or add information.")
        let answer: String
    }
    
    @Generable
    struct QuizQuestion: Hashable {
        @Guide(description: "A specific question based on a single fact, definition, or concept found in the source text. Start with: What, Who, When, Where, How, or Define.")
        let question: String
        
        @Guide(description: "List of answer options. Exactly as many as requested by the user. Exactly one or more must be correct, as specified.")
        let answers: [Answer]
        
        @Generable
        struct Answer: Hashable {
            @Guide(description: "A plausible answer option. Incorrect answers must be believable but clearly wrong based on the source text. Do not use 'all of the above' or 'none of the above'.")
            let answer: String
            
            @Guide(description: "True if this answer is correct according to the source text. False otherwise.")
            let isCorrect: Bool
        }
    }
}
