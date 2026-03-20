//
//  GenerateWithAIViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/03/2026.
//

import Foundation

@Observable
class GenerateWithAIViewModel {
    private(set) var importedFiles: [ImportedFile] = []
    private(set) var failedFiles: [FailedImport] = []
    
    private var extractedDocuments: [ExtractedDocument] = []
    
    var error: ImportError?
    
    var flashcardCount = 5.0
    var questionCount = 5.0
    
    var flashcardCountRounded: Int {
        Int(flashcardCount.rounded())
    }
    
    var questionCountRounded: Int {
        Int(questionCount.rounded())
    }
    
    var isGenerationDisabled: Bool {
        importedFiles.isEmpty || (flashcardCountRounded == 0 && questionCountRounded == 0)
    }
    
    func handleFileImport(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            handleUrls(urls)
        case .failure( _):
            self.error = ImportError.accessDenied
        }
    }
    
    private func handleUrls(_ urls: [URL]) {
        urls.forEach { url in
            guard url.startAccessingSecurityScopedResource() else { return }
            
            let alreadyExists = importedFiles.contains { $0.url == url }
            guard !alreadyExists else {
                url.stopAccessingSecurityScopedResource()
                return
            }
            
            let extractor = PDFDocumentExtractor(imageExtractor: ImageExtractor())
            do {
                let newFile = try ImportedFile(url: url)
                importedFiles.append(newFile)
                print("JESTES TU?")
                Task {
                    print("A TU?")
                    defer { url.stopAccessingSecurityScopedResource() }
                    let start = Date()
                    let newDocument = try? await extractor.extract(from: newFile)
                    if let newDocument {
                        print("A TU KURDE JESTEŚ?")
                        extractedDocuments.append(newDocument)
                        print(newDocument.rawText)
                    }
                    print(Date().timeIntervalSince(start))
                }
                
            } catch {
                url.stopAccessingSecurityScopedResource()
                let newFail = FailedImport(fileName: url.lastPathComponent, error: error)
                failedFiles.append(newFail)
            }
        }
    }
    
    func deleteFiles(at offsets: IndexSet) {
        importedFiles.remove(atOffsets: offsets)
    }
    
    struct FailedImport: Identifiable {
        let id = UUID()
        let fileName: String
        let error: Error
    }
}
