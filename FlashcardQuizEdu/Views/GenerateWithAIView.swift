//
//  GenerateWithAIView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/03/2026.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct GenerateWithAIView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: GenerateWithAIViewModel
    @State private var showingImporter = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    @State private var failedFiles: [GenerateWithAIViewModel.FailedImport] = [] // couldn't animate without
    let sectionSpacing: CGFloat = 15
    
    init(viewModel: GenerateWithAIViewModel) {
        self.vm = viewModel
    }
    
    var body: some View {
        Form {
            Section("MATERIAŁY ŹRÓDŁOWE") {
                Button("Dodaj pliki", systemImage: "paperclip") {
                    showingImporter = true
                }
                
                PhotosPicker(selection: $selectedPhotos, matching: .images) {
                    Label("Dodaj zdjęcia", systemImage: "photo")
                }
                
                Button("Dodaj błąd") {
                    vm.addFailedFile(GenerateWithAIViewModel.FailedImport(fileName: "AASDASO:DAJSD:OAJSD:", error: ImportError.fileUnreadable))
                }
            }
            .onChange(of: selectedPhotos) { handleSelectedPhotos() }
            
            ImportedDocumentsSectionView(
                documents: vm.importedDocuments,
                onDelete: vm.deleteFiles
            )
            .listSectionSpacing(sectionSpacing)
            
            ImportedImagesSectionView(images: vm.importedImages) { id in
                vm.deleteImage(id: id)
            }
            .listSectionSpacing(sectionSpacing)
                
            FailedFilesSectionView(
                files: failedFiles,
                onDelete: vm.removeFailedFiles
            )
            .listSectionSpacing(sectionSpacing)
            .onChange(of: vm.failedFiles) {
                withAnimation {
                    failedFiles = vm.failedFiles
                }
            }
            
            Section("ILOŚĆ FISZEK") {
                RoundingSlider(value: $vm.flashcardCount, range: 0...50)
            }
            
            Section("ILOŚĆ PYTAŃ") {
                RoundingSlider(value: $vm.questionCount, range: 0...50)
            }
        }
        .navigationTitle("Generuj z AI")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button("Generuj") {
                    vm.error = ImportError.accessDenied
                }
                .buttonStyle(.glassProminent)
                .font(.title3)
                .fontWeight(.semibold)
                .monospaced()
                .disabled(vm.isGenerationDisabled)
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [
                .pdf, .image
            ],
            allowsMultipleSelection: true
        ) { result in
            withAnimation {
                vm.handleFileImport(result)
            }
        }
        .alert(item: $vm.error) { error in
            Alert(
                title: Text(error.localizedDescription),
                message: Text(error.recoverySuggestion ?? "")
            )
        }
    }
    
    private func handleSelectedPhotos() {
        guard !selectedPhotos.isEmpty else { return }
        Task {
            await vm.handleSelectedPhotos(selectedPhotos)
            selectedPhotos.removeAll()
        }
    }
}

#Preview {
    GenerateWithAIView(viewModel: GenerateWithAIViewModel())
}
