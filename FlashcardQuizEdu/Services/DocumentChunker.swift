//
//  DocumentChunker.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct DocumentChunker {
//    private let configuration: StudySetGenerationConfiguration
    private let sentenceOverlapCount: Int
    private let tokenLimit: Int
    private let prompt: String
    private let instructions: String
    private let chunkSeparator: String
    
    init(configuration: StudySetGenerationConfiguration, chunkSeparator: String = "\n") {
        self.sentenceOverlapCount = configuration.sentenceOverlapCount
        self.tokenLimit = configuration.tokenLimit
        self.instructions = (configuration.flashcardInstructions.count > configuration.quizPrompt.count) ? configuration.flashcardInstructions : configuration.quizInstructions
        self.prompt = (configuration.flashcardPrompt.count > configuration.quizPrompt.count) ? configuration.flashcardPrompt : configuration.quizPrompt
        self.chunkSeparator = chunkSeparator
    }

    func chunks(for document: ExtractedDocument) async throws -> [String] {
        let documentText = document.markdownText
        guard !documentText.isEmpty else { return [] }

        if await fits(documentText) {
            return [documentText]
        }

        return try await sentenceAwareChunks(from: documentText)
    }

    func splitInHalf(_ chunk: String) -> [String] {
        let segments = sentenceSegments(from: chunk)
        guard segments.count > 1 else { return [] }

        let midpoint = segments.count / 2
        let firstHalf = segments[..<midpoint].joined(separator: chunkSeparator).trimmed()
        let secondHalf = segments[midpoint...].joined(separator: chunkSeparator).trimmed()

        return [firstHalf, secondHalf].filter { !$0.isEmpty }
    }

    private func sentenceAwareChunks(from chunk: String) async throws -> [String] {
        let segments = sentenceSegments(from: chunk)
        guard !segments.isEmpty else { return [] }

        var chunks = [String]()
        var startIndex = 0

        while startIndex < segments.count {
            if let endIndex = await largestFittingSegmentEnd(
                in: segments,
                startIndex: startIndex
            ) {
                let chunk = segments[startIndex..<endIndex].joined(separator: chunkSeparator).trimmed()
                guard !chunk.isEmpty else {
                    throw AIProcessingError.chunkTooLarge
                }

                chunks.append(chunk)

                guard endIndex < segments.count else { break }
                startIndex = nextStartIndex(
                    after: endIndex,
                    currentStartIndex: startIndex
                )
                continue
            }

            throw AIProcessingError.chunkTooLarge
        }

        return chunks
    }

    private func nextStartIndex(after endIndex: Int, currentStartIndex: Int) -> Int {
        let overlapCount = max(sentenceOverlapCount, 0)
        let overlappedStartIndex = max(endIndex - overlapCount, currentStartIndex + 1)
        return min(overlappedStartIndex, endIndex)
    }

    private func largestFittingSegmentEnd(
        in segments: [String],
        startIndex: Int
    ) async -> Int? {
        var low = startIndex + 1
        var high = segments.count
        var best: Int?

        while low <= high {
            let mid = (low + high) / 2
            let candidate = segments[startIndex..<mid].joined(separator: chunkSeparator).trimmed()

            if await fits(candidate) {
                best = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return best
    }

    private func sentenceSegments(from chunk: String) -> [String] {
        chunk
            .components(separatedBy: "\n\n")
            .map { $0.trimmed() }
            .filter { !$0.isEmpty }
            .flatMap { paragraph in
                let sentences = sentences(in: paragraph)
                return sentences.isEmpty ? [paragraph] : sentences
            }
    }

    private func sentences(in text: String) -> [String] {
        var sentences = [String]()

        text.enumerateSubstrings(
            in: text.startIndex..<text.endIndex,
            options: [.bySentences, .localized]
        ) { substring, _, _, _ in
            guard let substring else { return }
            let sentence = substring.trimmed()

            if !sentence.isEmpty {
                sentences.append(sentence)
            }
        }

        return sentences
    }

    private func fits(_ chunk: String) async -> Bool {
        guard let tokenCount = await tokenCount(for: chunk) else { return false }
        return tokenCount < tokenLimit
    }

    private func tokenCount(for chunk: String) async -> Int? {
        let model = SystemLanguageModel.default
        guard let chunkTokens = try? await model.tokenCount(for: prompt.appending(chunk)) else { return nil }
        guard let instructionsTokens = try? await model.tokenCount(for: instructions) else { return nil }

        return chunkTokens + instructionsTokens
    }
}
