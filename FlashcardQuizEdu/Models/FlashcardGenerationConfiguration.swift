//
//  FlashcardGenerationConfiguration.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 11/04/2026.
//

import Foundation
import FoundationModels

struct FlashcardGenerationConfiguration {
    static let `default` = Self.init(
        tokenLimit: Int(Double(SystemLanguageModel.default.contextSize) * 0.7),
        sentenceOverlapCount: 2,
        instructions: Instructions("You are an expert at creating high-quality study flashcards."),
        prompt: """
        Your task is to generate flashcards based ONLY on the provided text.
        
        STRICT RULES:
        - Use ONLY information explicitly present in the text
        - DO NOT use prior knowledge
        - DO NOT infer or guess missing information
        - If the text does not contain clear factual information, return empty output
        
        QUALITY RULES:
        - Focus on key facts, definitions, relationships, and mechanisms
        - Each flashcard must test a single concept
        - Questions must be specific and unambiguous
        - Answers must be concise (1–3 sentences max)
        
        VALIDATION STEP (MANDATORY):
        Before generating flashcards, verify:
        - Does the text contain concrete, factual information?
        - If NO → return an empty array
        
        TEXT:
        """
    )
    
    let tokenLimit: Int
    let sentenceOverlapCount: Int
    let instructions: Instructions
    let prompt: String
}
