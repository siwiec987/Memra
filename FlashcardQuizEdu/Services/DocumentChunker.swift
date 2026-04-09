//
//  DocumentChunker.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/04/2026.
//

import Foundation
import FoundationModels

struct DocumentChunker {
    let tokenLimit: Int
    let prompt: String
    let instructions: Instructions

    func chunks(for document: ExtractedDocument) async throws -> [String] {
        var chunks = [String]()
        var offset = 0
        var index = 1
        var previousChunk = ""

        while index <= document.pageCount - offset {
            let currentChunk = document.markdownText(pageLimit: index, offset: offset)

            guard let tokenCount = await tokenCount(for: currentChunk),
                  tokenCount < tokenLimit else {
                if previousChunk.isEmpty {
                    chunks.append(contentsOf: try await lineChunks(from: currentChunk))
                    offset += index
                } else {
                    chunks.append(previousChunk)
                    offset += index - 1
                }

                index = 1
                previousChunk = ""
                continue
            }

            index += 1
            previousChunk = currentChunk
        }

        if !previousChunk.isEmpty {
            chunks.append(previousChunk)
        }

        return chunks
    }

    private func lineChunks(from chunk: String) async throws -> [String] {
        var chunks = [String]()
        let lines = chunk.components(separatedBy: "\n")

        var processedLines = 0
        var prefixLength = max(lines.count / 2, 1)

        while processedLines < lines.count {
            let prefix = lines
                .dropFirst(processedLines)
                .prefix(prefixLength)
                .joined(separator: "\n")

            guard let tokenCount = await tokenCount(for: prefix),
                  tokenCount < tokenLimit else {
                prefixLength /= 2

                if prefixLength < max(Int(Double(lines.count) * 0.2), 1) {
                    throw DocumentChunkingError.lineChunkTooLarge
                }

                continue
            }

            chunks.append(prefix)
            processedLines += prefixLength
        }

        return chunks
    }

    private func tokenCount(for chunk: String) async -> Int? {
        let model = SystemLanguageModel.default
        guard let chunkTokens = try? await model.tokenCount(for: prompt.appending(chunk)) else { return nil }
        guard let instructionsTokens = try? await model.tokenCount(for: instructions) else { return nil }

        return chunkTokens + instructionsTokens
    }
}
