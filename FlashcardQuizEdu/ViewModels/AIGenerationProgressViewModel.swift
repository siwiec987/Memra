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
    private(set) var state: ProgressState = .idle
    
    @ObservationIgnored private let importedDocuments: [ImportedFile]
    @ObservationIgnored private let importedImages: [ImportedImage]
    @ObservationIgnored private let pdfExtractor: PDFDocumentExtractor
    @ObservationIgnored private let imageExtractor: ImageExtractor
    @ObservationIgnored private let flashcardGenerator: FlashcardGenerator
    
    init(importedDocuments: [ImportedFile], importedImages: [ImportedImage], pdfExtractor: PDFDocumentExtractor, imageExtractor: ImageExtractor, flashcardGenerator: FlashcardGenerator) {
        self.importedDocuments = importedDocuments
        self.importedImages = importedImages
        self.pdfExtractor = pdfExtractor
        self.imageExtractor = imageExtractor
        self.flashcardGenerator = flashcardGenerator
    }
    
    func perform() async {
        do {
            let extracted = try await extract()
            try await generate(from: extracted)
        } catch {
            state = .failed(error)
        }
    }
    
    func extract() async throws -> [ExtractedDocument] {
        var extractedDocuments = [ExtractedDocument]()
        
        for document in importedDocuments {
            state = .extracting(document.fileName)
            let extracted = try await pdfExtractor.extract(from: document)
            extractedDocuments.append(extracted)
        }
        
        for image in importedImages {
            let extractedPage = try await imageExtractor.extract(from: image.thumbnail)
            let extractedDocument = ExtractedDocument(sourceFileID: image.id, pages: [extractedPage])
            extractedDocuments.append(extractedDocument)
        }
        
        extractedDocuments.forEach { doc in
            print("document:", doc.markdownText)
        }
        
        return extractedDocuments
    }
    
    func generate(from documents: [ExtractedDocument]) async throws {
        state = .generating
        var flashcards = [GeneratedFlashcard]()
        for document in documents {
            let response = try await flashcardGenerator.generate(for: document)
            flashcards.append(contentsOf: response)
        }

        state = .success(flashcards)
    }
    
    enum ProgressState {
        case idle
        case extracting(String)
        case generating
        case success([GeneratedFlashcard])
        case failed(Error)
        
//        var id: String {
//            switch self {
//            case .extracting(let name): "extracting \(name)"
//            case .generating: "generating"
//            case .success(let flashcards): "result \(flashcards.map { $0.answer.prefix(10) })"
//            case .failed(let error): "error: \(error)"
//            }
//        }
//
//        static func == (lhs: Self, rhs: Self) -> Bool {
//            lhs.id == rhs.id
//        }
    }
}
