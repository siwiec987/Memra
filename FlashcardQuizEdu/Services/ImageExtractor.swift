//
//  ImageExtractor.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 19/03/2026.
//

import Foundation
import Vision

struct ImageExtractor {
    func extract(from image: CGImage) async throws -> ExtractedPage {
        var request = RecognizeDocumentsRequest()

        var options = request.textRecognitionOptions
        options.automaticallyDetectLanguage = true
        options.useLanguageCorrection = true
        options.minimumTextHeightFraction = 0.001
        request.textRecognitionOptions = options

        let observations = try await request.perform(on: image)
        guard let document = observations.first?.document else {
            throw ExtractError.fileEmpty
        }

        let sections = extractSections(from: document)
        return ExtractedPage(sections: sections)
    }

    private func extractSections(from document: DocumentObservation.Container) -> [PageSection] {
        var sections: [PageSection] = []

        let paragraph = normalized(document.text.transcript)
        sections.append(.paragraph(paragraph))

//        for list in document.lists {
//            let items = list.items.compactMap { item in
//                let text = normalized(item.itemString)
//                return text.isEmpty ? nil : text
//            }
//
//            guard !items.isEmpty else { continue }
//            sections.append(.list(items))
//        }

        for table in document.tables {
            let rows = table.rows
                .map { row in
                    row
                        .map { normalized($0.content.text.transcript) }
                        .filter { !$0.isEmpty }
                }
                .filter { !$0.isEmpty }

            guard !rows.isEmpty else { continue }
            sections.append(.table(rows))
        }

        if sections.isEmpty {
            let fallback = normalized(document.text.transcript)
            if !fallback.isEmpty {
                sections.append(.paragraph(fallback))
            }
        }

        return sections
    }

    private func normalized(_ text: String?) -> String {
        guard let text else { return "" }

        return text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
            .trimmed()
    }
}
