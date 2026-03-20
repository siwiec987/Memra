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
    
    func extract(from file: ImportedFile) async throws -> ExtractedDocument {
        guard let document = PDFDocument(url: file.url) else {
            throw ExtractError.fileUnreadable
        }
        
        let content = try await extractText(from: document)
        guard !content.isEmpty else {
            throw ExtractError.fileEmpty
        }
        
        return ExtractedDocument(sourceFileID: file.id, rawText: content, chunks: [])
    }
    
    private func extractText(from document: PDFDocument) async throws -> String {
        print("START extractText, stron:", document.pageCount)
        let result = try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for pageNumber in 0..<document.pageCount {
                group.addTask {
                    print("START strona", pageNumber)
                    guard let page = document.page(at: pageNumber)?.pageRef else {
                        throw ExtractError.couldNotOpenPage(number: pageNumber)
                    }
                    print("PAGE OK", pageNumber)
                    guard let cgImage = drawPDFPage(page: page)?.cgImage else {
                        throw ExtractError.couldNotOpenPage(number: pageNumber)
                    }
                    print("IMAGE OK", pageNumber)
                    let text = (try? await imageExtractor.extract(from: cgImage)) ?? ""
                    print("OCR OK", pageNumber)
                    print(text.prefix(30))
                    return (pageNumber, text)
                }
            }
            
            return try await group.reduce(into: [(Int, String)]()) { $0.append($1) }
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
                .joined(separator: "\n")
        }
        print("END extractText")
        return result
    }
    
//    private func extractText(from document: PDFDocument) throws -> String {
//        var result = ""
//        
//        for pageNumber in 0..<document.pageCount {
//            guard let page = document.page(at: pageNumber)?.pageRef else {
//                throw ExtractError.couldNotOpenPage(number: pageNumber)
//            }
//            guard let pageAsImage = drawPDFPage(page: page)?.cgImage else {
//                throw ExtractError.couldNotOpenPage(number: pageNumber)
//            }
//            
//            if let string = try? imageExtractor.extract(from: pageAsImage) {
//                result.append(string)
//                result.append("\n")
//            }
//        }
//        
//        return result
//    }
    
    private func drawPDFPage(page: CGPDFPage) -> UIImage? {
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
}

enum ExtractError: Error {
    case fileUnreadable
    case fileEmpty
    case couldNotOpenPage(number: Int)
}
