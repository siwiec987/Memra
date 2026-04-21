//
//  FlashcardGenerator.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct StudySetGenerator {
    private let configuration: StudySetGenerationConfiguration
    private let chunker: DocumentChunker
    private let maxSplitDepth: Int
    
    init(configuration: StudySetGenerationConfiguration, maxSplitDepth: Int = 6) {
        self.configuration = configuration
        self.chunker = DocumentChunker(configuration: configuration)
        self.maxSplitDepth = maxSplitDepth
    }
    
    func generate(for documents: [ExtractedDocument]) async throws -> GeneratedStudySet {
        var flashcards = [GeneratedStudySet.Flashcard]()
        var quiz = [GeneratedStudySet.QuizQuestion]()
        var chunks = [String]()
        
        for document in documents {
            chunks.append(contentsOf: try await chunker.chunks(for: document))
        }
        
        for chunk in chunks {
            let cards: [GeneratedStudySet.Flashcard] = try await generate(
                for: chunk,
                instructions: configuration.flashcardInstructions,
                prompt: configuration.flashcardPrompt
            )
            flashcards.append(contentsOf: cards)
            
            let quizQuestions: [GeneratedStudySet.QuizQuestion] = try await generate(
                for: chunk,
                instructions: configuration.quizInstructions,
                prompt: configuration.quizPrompt
            )
            quiz.append(contentsOf: quizQuestions)
        }
        
        var generatedStudySet = GeneratedStudySet(name: "", flashcards: flashcards, quiz: quiz)
        
        guard let firstChunk = chunks.first, !flashcards.isEmpty || !quiz.isEmpty else { return generatedStudySet }
        guard let suggestedName = try? await generateName(for: firstChunk) else { return generatedStudySet }
        
        return GeneratedStudySet(name: suggestedName, flashcards: flashcards, quiz: quiz)
    }
    
    private func generateName(for chunk: String) async throws -> String {
        let prompt = """
        Generate a short name for a study set based on the text below.

        RULES:
        - Maximum 3 words
        - Descriptive and specific to the content
        - No punctuation at the end
        - Output language should match the language of the provided text

        TEXT:
        \(chunk)    
        """

        let response = try await LanguageModelSession().respond(to: prompt)
        return response.content
    }
    
    private func generate<Content: Generable>(for chunk: String, instructions: String, prompt: String, splitDepth: Int = 0) async throws -> [Content] {
        do {
            let response = try await LanguageModelSession(instructions: instructions).respond(
                to: prompt.appending(chunk),
                generating: [Content].self,
                options: .init(temperature: 0.05)
            )
            
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            guard splitDepth < maxSplitDepth else {
                throw AIProcessingError.chunkTooLarge
            }
            
            let subchunks = chunker.splitInHalf(chunk)
            guard subchunks.count == 2 else {
                throw AIProcessingError.chunkTooLarge
            }
            
            var result = [Content]()
            for subchunk in subchunks {
                let subresult: [Content] = try await generate(
                    for: subchunk,
                    instructions: instructions,
                    prompt: prompt,
                    splitDepth: splitDepth + 1
                )
                result.append(contentsOf: subresult)
            }
            
            return result
        }
    }

//    private func generateFlashcards(for chunk: String, splitDepth: Int = 0) async throws -> [GeneratedStudySet.Flashcard] {
//        do {
//            let response = try await LanguageModelSession(instructions: configuration.flashcardInstructions).respond(
//                to: configuration.flashcardPrompt.appending(chunk),
//                generating: [GeneratedStudySet.Flashcard].self,
//                options: .init(temperature: 0.05)
//            )
//
//            return response.content
//        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
//            guard splitDepth < maxSplitDepth else {
//                throw AIProcessingError.chunkTooLarge
//            }
//
//            let subchunks = chunker.splitInHalf(chunk)
//            guard subchunks.count == 2 else {
//                throw AIProcessingError.chunkTooLarge
//            }
//
//            var result = [GeneratedStudySet.Flashcard]()
//            for subchunk in subchunks {
//                let flashcards = try await generateFlashcards(
//                    for: subchunk,
//                    splitDepth: splitDepth + 1
//                )
//                result.append(contentsOf: flashcards)
//            }
//
//            return result
//        }
//    }
}
