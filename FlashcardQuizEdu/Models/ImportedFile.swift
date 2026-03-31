//
//  ImportedFile.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/03/2026.
//

import Foundation
import UniformTypeIdentifiers

struct ImportedFile: Identifiable, Sendable {
    let id: UUID
    let url: URL
    let fileName: String
    let fileSize: Int?
    let contentType: UTType
    
    var fileSizeFormatted: String {
        guard let fileSize else { return "Brak rozmiaru" }
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    init(url: URL, fileSize: Int?, contentType: UTType) throws {
        self.id = UUID()
        self.url = url
        self.fileName = url.lastPathComponent

        guard contentType.conforms(to: .pdf) else {
            throw ImportError.unsupportedContentType
        }

        self.fileSize = fileSize
        self.contentType = contentType
    }
}
