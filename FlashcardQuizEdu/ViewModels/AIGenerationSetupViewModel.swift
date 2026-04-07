//
//  AIGenerationSetupViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/03/2026.
//

import Foundation
import UniformTypeIdentifiers
import _PhotosUI_SwiftUI

@Observable
@MainActor
class AIGenerationSetupViewModel {
    private(set) var importedDocuments: [ImportedFile] = []
    private(set) var importedImages: [ImportedImage] = []
    private(set) var failedFiles: [FailedImport] = []
    
    @ObservationIgnored
    private var failedFilesRemovalTasks: [UUID: Task<Void, Never>] = [:]
    
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
        (importedDocuments.isEmpty && importedImages.isEmpty) ||
        (flashcardCountRounded == 0 && questionCountRounded == 0)
    }
    
    func handleFileImport(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            handleUrls(urls)
        case .failure( _):
            self.error = ImportError.accessDenied
        }
    }
    
    func handleSelectedPhotos(_ photos: [PhotosPickerItem]) async {
        for photo in photos {
            let suggestedName = "Image: " + (photo.itemIdentifier ?? "\(Date())")
            
            do {
                guard let contentType = photo.supportedContentTypes.first else {
                    throw ImportError.imageDecodingFailed
                }

                let data = try await photo.loadTransferable(type: Data.self)
                guard let data else { throw ImportError.imageDecodingFailed }
                
                let newImage = try ImportedImage(data: data, suggestedName: suggestedName, contentType: contentType)
                importedImages.insert(newImage, at: 0)
            } catch {
                let newFail = FailedImport(fileName: suggestedName, error: error)
                addFailedFile(newFail)
            }
        }
    }
    
    func deleteFiles(at offsets: IndexSet) {
        importedDocuments.remove(atOffsets: offsets)
    }
    
    func deleteImage(id: UUID) {
        importedImages.removeAll { $0.id == id }
    }
    
    private func handleUrls(_ urls: [URL]) {
        urls.forEach { url in
            do {
                guard url.startAccessingSecurityScopedResource() else { throw ImportError.accessDenied }
                defer { url.stopAccessingSecurityScopedResource() }

                let (contentType, fileSize) = try resourceMetadata(for: url)

                let url = createTemporaryFile(from: url)
                if contentType.conforms(to: .image) {
                    try handleImage(url, imageSize: fileSize, contentType: contentType)
                    return
                }

                if contentType.conforms(to: .pdf) {
                    let newFile = try ImportedFile(url: url, fileSize: fileSize, contentType: contentType)
                    let alreadyExists = importedDocuments.contains {
                        $0.url == newFile.url || ($0.fileName == newFile.fileName && $0.fileSize == newFile.fileSize)
                    }
                    if alreadyExists { return }

                    importedDocuments.append(newFile)
                    return
                }

                throw ImportError.unsupportedContentType
            } catch {
                let newFail = FailedImport(fileName: url.lastPathComponent, error: error)
                addFailedFile(newFail)
            }
        }
    }

    private func handleImage(_ url: URL, imageSize: Int?, contentType: UTType) throws {
        let newImage = try ImportedImage(url: url, imageSize: imageSize, contentType: contentType)
        let alreadyExists = importedImages.contains {
            $0.url == newImage.url || ($0.imageName == newImage.imageName && $0.imageSize == newImage.imageSize)
        }
        if alreadyExists { return }
        
        importedImages.insert(newImage, at: 0)
    }

    private func resourceMetadata(for url: URL) throws -> (contentType: UTType, fileSize: Int?) {
        let resourceValues = try url.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey])
        guard let contentType = resourceValues.contentType else {
            throw ImportError.fileUnreadable
        }

        return (contentType, resourceValues.fileSize)
    }
    
    private func createTemporaryFile(from url: URL) -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appending(component: url.lastPathComponent)
        try? FileManager.default.copyItem(at: url, to: tempURL)
        return tempURL
    }
    
    private func addFailedFile(_ failed: FailedImport) {
        failedFiles.append(failed)
        scheduleFailedFileRemoval(for: failed.id)
    }
    
    private func scheduleFailedFileRemoval(for id: UUID) {
        failedFilesRemovalTasks[id]?.cancel()
        
        let newTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            
            self?.removeFailedFile(id: id)
        }
        failedFilesRemovalTasks[id] = newTask
    }
    
    private func removeFailedFile(id: UUID) {
        failedFilesRemovalTasks[id]?.cancel()
        failedFilesRemovalTasks.removeValue(forKey: id)
        failedFiles.removeAll { $0.id == id }
    }
    
    func removeFailedFiles(_ indexSet: IndexSet) {
        indexSet.forEach { i in
            removeFailedFile(id: failedFiles[i].id)
        }
    }
}
