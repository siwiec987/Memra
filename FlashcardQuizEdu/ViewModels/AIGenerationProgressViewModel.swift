//
//  AIGenerationProgressViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 03/04/2026.
//

import Foundation

@MainActor
@Observable
final class AIGenerationProgressViewModel {
    private(set) var state: ProgressState = .extracting
    
    @ObservationIgnored private let pdfExtractor: PDFDocumentExtractor
    @ObservationIgnored private let imageExtractor: ImageExtractor
    @ObservationIgnored private let importedDocuments: [ImportedFile]
    @ObservationIgnored private let importedImages: [ImportedImage]
    
    @ObservationIgnored private var extractedDocuments: [ExtractedDocument] = []
//    @ObservationIgnored private let importedImages: [ImportedImage]
    
    init(importedDocuments: [ImportedFile], importedImages: [ImportedImage], pdfExtractor: PDFDocumentExtractor, imageExtractor: ImageExtractor) {
        self.importedDocuments = importedDocuments
        self.importedImages = importedImages
        self.pdfExtractor = pdfExtractor
        self.imageExtractor = imageExtractor
    }
    
    func perform() async {
        do {
            let extracted = try await extract()
            try await generate(from: extracted)
        } catch {
            state = .error(error)
        }
    }
    
    func extract() async throws -> [ExtractedDocument] {
        state = .extracting
        var extractedDocuments = [ExtractedDocument]()
        
        for document in importedDocuments {
            let extracted = try await pdfExtractor.extract(from: document)
            extractedDocuments.append(extracted)
        }
        
        return extractedDocuments
    }
    
    func generate(from documents: [ExtractedDocument]) async throws {
        state = .generating
        let generator = FlashcardGenerator()
        var flashcards = [GeneratedFlashcard]()
        for document in documents {
            let response = try await generator.generate(for: document)
            flashcards.append(contentsOf: response)
        }

        state = .result(flashcards)
    }
    
    enum ProgressState: Equatable, Identifiable {
        case extracting
        case generating
        case result([GeneratedFlashcard])
        case error(Error)
        
        var id: String {
            switch self {
            case .extracting: "extracting"
            case .generating: "generating"
            case .result(let flashcards): "result \(flashcards.map { $0.answer.prefix(10) })"
            case .error(let error): "error: \(error)"
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}
