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
    
    init(url: URL) throws {
        self.id = UUID()
        self.url = url
        self.fileName = url.lastPathComponent
        
        guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey]) else {
            throw ImportError.accessDenied
        }
        guard let contentType = resourceValues.contentType else {
            throw ImportError.fileUnreadable
        }
        
        self.fileSize = resourceValues.fileSize
        self.contentType = contentType
    }
}
