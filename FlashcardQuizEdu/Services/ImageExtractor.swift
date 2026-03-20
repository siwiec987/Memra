//
//  ImageExtractor.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 19/03/2026.
//

import Foundation
import Vision

struct ImageExtractor {
    func extract(from image: CGImage) async throws -> String {
        let request = VNRecognizeTextRequest()
        let requestHandler = VNImageRequestHandler(cgImage: image)
        
        try requestHandler.perform([request])
        return request.results?.compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n") ?? ""
    }
}
