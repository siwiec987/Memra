//
//  DocumentChunker.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct DocumentChunker {
    private let configuration: FlashcardGenerationConfiguration
    
    init(configuration: FlashcardGenerationConfiguration) {
        self.configuration = configuration
    }

    func chunks(for document: ExtractedDocument) async throws -> [String] {
        let pageTexts = document.pages
            .map(\.markdownText)
            .map { $0.trimmed() }
            .filter { !$0.isEmpty }

        guard !pageTexts.isEmpty else { return [] }

        var chunks = [String]()
        var currentChunk = ""

        for pageText in pageTexts {
            let candidate = join(currentChunk, with: pageText)

            if await fits(candidate) {
                currentChunk = candidate
                continue
            }

            if !currentChunk.isEmpty {
                chunks.append(currentChunk)
                currentChunk = ""
            }

            if await fits(pageText) {
                currentChunk = pageText
            } else {
                chunks.append(contentsOf: try await lineChunks(from: pageText))
            }
        }

        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }

        return chunks
    }

    func splitInHalf(_ chunk: String) -> [String] {
        let lines = chunk
            .components(separatedBy: "\n")
            .map { $0.trimmed() }
            .filter { !$0.isEmpty }

        guard lines.count > 1 else { return [] }

        let midpoint = lines.count / 2
        let firstHalf = lines[..<midpoint].joined(separator: "\n").trimmed()
        let secondHalf = lines[midpoint...].joined(separator: "\n").trimmed()

        return [firstHalf, secondHalf].filter { !$0.isEmpty }
    }

    private func lineChunks(from chunk: String) async throws -> [String] {
        let lines = chunk
            .components(separatedBy: "\n")
            .map { $0.trimmed() }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { return [] }

        var chunks = [String]()
        var startIndex = 0

        while startIndex < lines.count {
            guard let endIndex = await largestFittingLineEnd(
                in: lines,
                startIndex: startIndex
            ) else {
                throw AIProcessingError.chunkTooLarge
            }

            let chunk = lines[startIndex..<endIndex].joined(separator: "\n").trimmed()
            guard !chunk.isEmpty else {
                throw AIProcessingError.chunkTooLarge
            }

            chunks.append(chunk)
            startIndex = endIndex
        }

        return chunks
    }

    private func largestFittingLineEnd(
        in lines: [String],
        startIndex: Int
    ) async -> Int? {
        var low = startIndex + 1
        var high = lines.count
        var best: Int?

        while low <= high {
            let mid = (low + high) / 2
            let candidate = lines[startIndex..<mid].joined(separator: "\n").trimmed()

            if await fits(candidate) {
                best = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return best
    }

    private func fits(_ chunk: String) async -> Bool {
        guard let tokenCount = await tokenCount(for: chunk) else { return false }
        return tokenCount < configuration.tokenLimit
    }

    private func join(_ lhs: String, with rhs: String) -> String {
        guard !lhs.isEmpty else { return rhs }
        guard !rhs.isEmpty else { return lhs }
        return "\(lhs)\n\n\(rhs)"
    }

    private func tokenCount(for chunk: String) async -> Int? {
        let model = SystemLanguageModel.default
        guard let chunkTokens = try? await model.tokenCount(for: configuration.prompt.appending(chunk)) else { return nil }
        guard let instructionsTokens = try? await model.tokenCount(for: configuration.instructions) else { return nil }

        return chunkTokens + instructionsTokens
    }
}
