//
//  ImportedImage.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/03/2026.
//

import CoreImage
import ImageIO
import Foundation
import UniformTypeIdentifiers

struct ImportedImage: Identifiable, Sendable {
    let id: UUID
    let imageName: String
    let imageSize: Int?
    let contentType: UTType
    private(set) var thumbnail: CGImage
    let url: URL?
    
    var fileSizeFormatted: String {
        guard let imageSize else { return "Brak rozmiaru" }
        return ByteCountFormatter.string(fromByteCount: Int64(imageSize), countStyle: .file)
    }
    
    init(url: URL, imageSize: Int?, contentType: UTType) throws {
        self.id = UUID()
        self.url = url
        self.imageName = url.lastPathComponent

        guard contentType.conforms(to: .image) else {
            throw ImportError.unsupportedContentType
        }

        self.imageSize = imageSize
        self.contentType = contentType
        self.thumbnail = try Self.makeCGImage(from: url)
    }
    
    init(data: Data, suggestedName: String, contentType: UTType) throws {
        self.id = UUID()
        self.url = nil
        self.imageName = suggestedName
        
        self.imageSize = nil
        self.contentType = contentType
        self.thumbnail = try Self.makeCGImage(from: data)
    }
    
    private static func makeCGImage(from url: URL) throws -> CGImage {
        let data = try Data(contentsOf: url)
        return try makeCGImage(from: data)
    }
    
    private static func makeCGImage(from data: Data) throws -> CGImage {
        guard let newImageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImportError.imageDecodingFailed
        }
        guard let cgImage = CGImageSourceCreateImageAtIndex(newImageSource, 0, nil) else {
            throw ImportError.imageDecodingFailed
        }

        let props = CGImageSourceCopyPropertiesAtIndex(newImageSource, 0, nil) as? [CFString: Any]
        let raw = props?[kCGImagePropertyOrientation] as? UInt32
        let exif = raw.flatMap(CGImagePropertyOrientation.init(rawValue:)) ?? .up
        
        let ciImage = CIImage(cgImage: cgImage).oriented(exif)
        let context = CIContext(options: nil)

        guard let normalized = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw ImportError.imageDecodingFailed
        }

        return normalized
    }
}
