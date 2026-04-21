//
//  FlashcardGenerationConfiguration.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 11/04/2026.
//

import Foundation
import FoundationModels

struct StudySetGenerationConfiguration {
    static let `default` = Self.init(
        tokenLimit: Int(Double(SystemLanguageModel.default.contextSize) * 0.7),
        sentenceOverlapCount: 2,
        flashcardInstructions: """
        You are an expert at creating high-quality study flashcards. Your only job is to extract facts from text and turn them into flashcards.
        You do not explain, summarize, or add anything beyond what is written in the text.
        """,
        quizInstructions: """
        You are an expert at creating high-quality quiz questions. Your only job is to extract facts from text and turn them into quiz questions.
        You do not explain, summarize, or add anything beyond what is written in the text.
        """,
        flashcardPrompt: """
        Generate flashcards based ONLY on the text below.

        RULES:
        - Use ONLY information explicitly stated in the text
        - DO NOT use prior knowledge
        - DO NOT infer or guess missing information
        - Each flashcard tests exactly one fact, definition, term, or relationship
        - Questions must be specific and answerable solely from the text
        - Answers: 1–3 sentences, no padding
        - Minimum 3 flashcards if the text contains sufficient factual content
        - Output language should match the language of the provided text

        TEXT:
        """,
        quizPrompt: """
        Generate quiz questions based ONLY on the text below.

        CONFIGURATION:
        - Answers per question: 4
        - Multiple correct answers allowed: NO

        RULES:
        - Use ONLY information explicitly stated in the text
        - DO NOT use prior knowledge
        - DO NOT infer or guess missing information
        - Each question tests exactly one fact, definition, term, or relationship
        - Each question must have exactly 4 answer options
        - Exactly one answer must be correct
        - Incorrect answers must be plausible but clearly wrong based on the text
        - Do not use 'all of the above' or 'none of the above' as answer options
        - Questions must be specific and answerable solely from the text
        - Output language should match the language of the provided text

        TEXT:
        """
    )
    
    let tokenLimit: Int
    let sentenceOverlapCount: Int
    let flashcardInstructions: String
    let quizInstructions: String
    let flashcardPrompt: String
    let quizPrompt: String
}
