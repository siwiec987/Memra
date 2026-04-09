//
//  FlashcardGenerator.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct FlashcardGenerator {
    private let tokenLimit = Int(Double(SystemLanguageModel.default.contextSize) * 0.75)
    private let instructions = Instructions("You are an expert at creating high-quality study flashcards.")
    private let prompt = """
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
    
    func generate(for document: ExtractedDocument) async throws -> [GeneratedFlashcard] {
        var result = [GeneratedFlashcard]()
        let chunker = DocumentChunker(
            tokenLimit: tokenLimit,
            prompt: prompt,
            instructions: instructions
        )
        let chunks = try await chunker.chunks(for: document)
        
        for chunk in chunks {
            let part = try await LanguageModelSession().respond(generating: [GeneratedFlashcard].self, prompt: { prompt.appending(chunk) })
            result.append(contentsOf: part.content)
        }
        
        return result
    }
}
