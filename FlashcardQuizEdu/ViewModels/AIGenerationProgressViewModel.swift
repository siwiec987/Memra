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
    private(set) var state: ProgressState = .starting
    
    @ObservationIgnored private let importedDocuments: [ImportedFile]
    @ObservationIgnored private let importedImages: [ImportedImage]
    @ObservationIgnored private let pdfExtractor: PDFDocumentExtractor
    @ObservationIgnored private let imageExtractor: ImageExtractor
    @ObservationIgnored private let studySetGenerator: StudySetGenerator
    
    private(set) var generatedStudySet: GeneratedStudySet?
    
    var isGeneratedStudySetEmpty: Bool {
        guard let generatedStudySet else { return true }
        return generatedStudySet.flashcards.isEmpty &&
        generatedStudySet.quiz.isEmpty
    }
    
    init(importedDocuments: [ImportedFile], importedImages: [ImportedImage], pdfExtractor: PDFDocumentExtractor, imageExtractor: ImageExtractor, studySetGenerator: StudySetGenerator) {
        self.importedDocuments = importedDocuments
        self.importedImages = importedImages
        self.pdfExtractor = pdfExtractor
        self.imageExtractor = imageExtractor
        self.studySetGenerator = studySetGenerator
    }
    
    func perform() async {
        generatedStudySet = nil
        state = .starting
        
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
        
        return extractedDocuments
    }
    
    func generate(from documents: [ExtractedDocument]) async throws {
        state = .generating
        let response = try await studySetGenerator.generate(for: documents)
        generatedStudySet = response
        state = .completed
    }
    
    enum ProgressState: Equatable, Identifiable {
        case starting
        case extracting(String)
        case generating
        case completed
        case failed(Error)
        
        var id: String {
            switch self {
            case .starting:
                "starting"
            case .extracting(let name):
                "extracting \(name)"
            case .generating:
                "generating"
            case .completed:
                "completed"
            case .failed(let error):
                "failed \(error)"
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}
