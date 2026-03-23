//
//  PDFDocumentExtractor.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 18/03/2026.
//

import Foundation
import PDFKit

struct PDFDocumentExtractor: DocumentExtractor {
    let imageExtractor: ImageExtractor
    
    init(imageExtractor: ImageExtractor = ImageExtractor()) {
        self.imageExtractor = imageExtractor
    }
    
    func extract(from file: ImportedFile) async throws -> ExtractedDocument {
        guard let pdf = PDFDocument(url: file.url) else { throw ExtractError.fileUnreadable }
        let pages = try await extractText(from: pdf)
        
        guard !pages.isEmpty else {
            throw ExtractError.fileEmpty
        }
        
        return ExtractedDocument(sourceFileID: file.id, pages: pages)
    }
    
    private func extractText(from pdf: PDFDocument) async throws -> [ExtractedPage] {
        var renderedPages: [CGImage] = []
        var extractedPages: [ExtractedPage] = []
        
        for pageNumber in 0..<pdf.pageCount {
            guard let page = pdf.page(at: pageNumber) else { continue }
            guard let image = drawPDFPage(page) else { continue }
            renderedPages.append(image)
        }
        
        extractedPages = try await withThrowingTaskGroup { group in
            let maxTasks = min(5, pdf.pageCount)
            for index in 0..<maxTasks {
                let page = renderedPages[index]
                group.addTask {
                    let extractedPage = try await imageExtractor.extract(from: page)
                    return (index, extractedPage)
                }
            }
            
            var allPages: [Int: ExtractedPage] = [:]
            var nextIndex = maxTasks
            for try await (pageNumber, page) in group {
                allPages[pageNumber] = page
                
                if nextIndex < renderedPages.count {
                    let currentIndex = nextIndex
                    let page = renderedPages[currentIndex]
                    renderedPages.remove(at: currentIndex)
                    group.addTask {
                        let extractedPage = try await imageExtractor.extract(from: page)
                        return (currentIndex, extractedPage)
                    }
                    nextIndex += 1
                }
            }
            
            return (0..<allPages.count).compactMap { allPages[$0] }
        }
        
        return extractedPages
    }
    
    private func drawPDFPage(_ page: PDFPage) -> CGImage? {
        autoreleasepool {
            guard let pageRef = page.pageRef else { return nil }
            let pageRect = pageRef.getBoxRect(.mediaBox)
            let targetWidth: CGFloat = 1000
            let scale = min(1, targetWidth / pageRect.width)
            let renderSize = CGSize(
                width: pageRect.width * scale,
                height: pageRect.height * scale
            )
            
            return page.thumbnail(of: renderSize, for: .mediaBox).cgImage
        }
    }
}
