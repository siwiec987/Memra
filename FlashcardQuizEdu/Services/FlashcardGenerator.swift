//
//  FlashcardGenerator.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct FlashcardGenerator {
    private let configuration: FlashcardGenerationConfiguration
    private let chunker: DocumentChunker
    private let maxSplitDepth: Int
    
    init(configuration: FlashcardGenerationConfiguration, maxSplitDepth: Int = 6) {
        self.configuration = configuration
        self.chunker = DocumentChunker(configuration: configuration)
        self.maxSplitDepth = maxSplitDepth
    }
    
    func generate(for document: ExtractedDocument) async throws -> [GeneratedFlashcard] {
        var result = [GeneratedFlashcard]()
        let chunks = try await chunker.chunks(for: document)
        
        for chunk in chunks {
            let flashcards = try await generateFlashcards(for: chunk)
            result.append(contentsOf: flashcards)
        }
        
        return result
    }

    private func generateFlashcards(for chunk: String, splitDepth: Int = 0) async throws -> [GeneratedFlashcard] {
        do {
            let response = try await LanguageModelSession().respond(
                generating: [GeneratedFlashcard].self,
                prompt: { configuration.prompt.appending(chunk) }
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

            var result = [GeneratedFlashcard]()
            for subchunk in subchunks {
                let flashcards = try await generateFlashcards(
                    for: subchunk,
                    splitDepth: splitDepth + 1
                )
                result.append(contentsOf: flashcards)
            }

            return result
        }
    }
}
