//
//  FlashcardGenerator.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct StudySetGenerator {
    private let flashcardRequest: GenerationRequest?
    private let quizRequest: GenerationRequest?
    private let studySetNamePrompt: String
    
    private let chunker: DocumentChunker?
    private let maxSplitDepth: Int
    private let modelTemperature: Double
    
    init(generateFlashcards: Bool, quizConfiguration: QuizConfiguration?, maxSplitDepth: Int = 6, modelTemperature: Double = 0.05) {
        self.maxSplitDepth = maxSplitDepth
        self.modelTemperature = modelTemperature
        
        self.flashcardRequest = generateFlashcards ? Self.makeFlashcardRequest() : nil
        self.quizRequest = quizConfiguration.map(Self.makeQuizRequest)
        self.studySetNamePrompt = Self.makeStudySetNamePrompt()
        
        let chunkerInstructions: String?
        let chunkerPrompt: String?
        if let flashcardRequest, let quizRequest {
            chunkerInstructions = flashcardRequest.instructions.count > quizRequest.instructions.count ? flashcardRequest.instructions : quizRequest.instructions
            chunkerPrompt = flashcardRequest.prompt.count > quizRequest.prompt.count ? flashcardRequest.prompt : quizRequest.prompt
        } else {
            chunkerInstructions = flashcardRequest?.instructions ?? quizRequest?.instructions
            chunkerPrompt = flashcardRequest?.prompt ?? quizRequest?.prompt
        }
        
        if let chunkerInstructions, let chunkerPrompt {
            self.chunker = DocumentChunker(
                tokenLimit: Int(Double(SystemLanguageModel.default.contextSize) * 0.7),
                sentenceOverlapCount: 2,
                instructions: chunkerInstructions,
                prompt: chunkerPrompt,
                chunkSeparator: "\n"
            )
        } else {
            self.chunker = nil
        }
        
    }
    
    func generate(for documents: [ExtractedDocument]) async throws -> GeneratedStudySet {
        var flashcards = [GeneratedStudySet.Flashcard]()
        var quiz = [GeneratedStudySet.QuizQuestion]()
        var chunks = [String]()
        
        if let chunker {
            for document in documents {
                chunks.append(contentsOf: try await chunker.chunks(for: document))
            }
        }
        
        for chunk in chunks {
            if let flashcardRequest {
                let cards: [GeneratedStudySet.Flashcard] = try await generate(
                    for: chunk,
                    instructions: flashcardRequest.instructions,
                    prompt: flashcardRequest.prompt
                )
                flashcards.append(contentsOf: cards)
            }
            
            if let quizRequest {
                let quizQuestions: [GeneratedStudySet.QuizQuestion] = try await generate(
                    for: chunk,
                    instructions: quizRequest.instructions,
                    prompt: quizRequest.prompt
                )
                quiz.append(contentsOf: quizQuestions)
            }
        }
        
        let generatedStudySet = GeneratedStudySet(name: "", flashcards: flashcards, quiz: quiz)
        guard let firstChunk = chunks.first, !flashcards.isEmpty || !quiz.isEmpty else { return generatedStudySet }
        guard let suggestedName = try? await generateName(for: firstChunk) else { return generatedStudySet }
        
        return GeneratedStudySet(name: suggestedName, flashcards: flashcards, quiz: quiz)
    }
    
    private func generateName(for chunk: String) async throws -> String {
        let prompt = studySetNamePrompt.appending(chunk)
        let response = try await LanguageModelSession().respond(to: prompt)
        return response.content
    }
    
    private func generate<Content: Generable>(for chunk: String, instructions: String, prompt: String, splitDepth: Int = 0) async throws -> [Content] {
        do {
            let response = try await LanguageModelSession(instructions: instructions).respond(
                to: prompt.appending(chunk),
                generating: [Content].self,
                options: .init(temperature: modelTemperature)
            )
            
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            guard splitDepth < maxSplitDepth else {
                throw AIProcessingError.chunkTooLarge
            }
            
            let subchunks = chunker?.splitInHalf(chunk)
            guard let subchunks, subchunks.count == 2 else {
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
    
    private static func makeFlashcardRequest() -> GenerationRequest {
        GenerationRequest(
            instructions: """
            You are an expert at creating high-quality study flashcards. Your only job is to extract facts from text and turn them into flashcards.
            You do not explain, summarize, or add anything beyond what is written in the text.
            """,
            prompt: """
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
            """
        )
    }
    
    private static func makeQuizRequest(from config: QuizConfiguration) -> GenerationRequest {
        GenerationRequest(
            instructions: """
            You are an expert at creating high-quality quiz questions. Your only job is to extract facts from text and turn them into quiz questions.
            You do not explain, summarize, or add anything beyond what is written in the text.
            """,
            prompt: """
            Generate quiz questions based ONLY on the text below.

            CONFIGURATION:
            - Answers per question: \(config.answersPerQuestion)
            - Multiple correct answers allowed: \(config.allowsMultipleCorrectAnswers)

            RULES:
            - Use ONLY information explicitly stated in the text
            - DO NOT use prior knowledge
            - DO NOT infer or guess missing information
            - Each question tests exactly one fact, definition, term, or relationship
            - Each question must have exactly \(config.answersPerQuestion) answer options
            - \(config.allowsMultipleCorrectAnswers ? "At least one " : "Exactly one ") answer must be correct
            - Incorrect answers must be plausible but clearly wrong based on the text
            - Do not use 'all of the above' or 'none of the above' as answer options
            - Questions must be specific and answerable solely from the text
            - Output language should match the language of the provided text

            TEXT:
            """
        )
    }
    
    private static func makeStudySetNamePrompt() -> String {
        """
        Generate a short name for a study set based on the text below.

        RULES:
        - Maximum 3 words
        - Descriptive and specific to the content
        - No punctuation at the end
        - Output language should match the language of the provided text

        TEXT:    
        """
    }
    
    struct QuizConfiguration {
        let answersPerQuestion: Int
        let allowsMultipleCorrectAnswers: Bool
    }
    
    private struct GenerationRequest {
        let instructions: String
        let prompt: String
    }
}
