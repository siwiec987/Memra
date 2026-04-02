//
//  GenerateWithAIView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/03/2026.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

// TODO: MOŻNA FAILEDFILES ZNIKAĆ PO JAKIMŚ CZASIE

struct GenerateWithAIView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: GenerateWithAIViewModel
    @State private var showingImporter = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
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
                
                Button("Dodaj błąd", systemImage: "exclamationmark.circle.fill") {
                    vm.addFailedFile()
                }
                .tint(.red)
            }
            .onChange(of: selectedPhotos) { _, new in
                guard !new.isEmpty else { return }
                Task {
                    await vm.handleSelectedPhotos(new)
                    selectedPhotos.removeAll()
                }
            }
            
            Section {
                ImportedDocumentsView(
                    documents: vm.importedDocuments,
                    onDelete: vm.deleteFiles
                )
            }
            
            Section {
                if !vm.importedImages.isEmpty {
                    ImportedImagesView(images: vm.importedImages) { id in
                        vm.deleteImage(id: id)
                    }
                    .listRowInsets(.init())
                }
            }
            .listSectionSpacing(10)
                
            Section {
                ForEach(vm.failedFiles) { failed in
                    Label {
                        VStack(alignment: .leading) {
                            Text(failed.fileName)
                            Text(failed.error.localizedDescription)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.circle.fill")
                    }
                }
                .listItemTint(.red)
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
}

#Preview {
    GenerateWithAIView(viewModel: GenerateWithAIViewModel())
}
