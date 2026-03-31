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
            }
            .onChange(of: selectedPhotos) { _, new in
                guard !new.isEmpty else { return }
                Task {
                    await vm.handleSelectedPhotos(new)
                    selectedPhotos.removeAll()
                }
            }
            
            Section {
                ForEach(vm.importedDocuments) { file in
                    Label {
                        VStack(alignment: .leading) {
                            Text(file.fileName)
                            Text(file.fileSizeFormatted)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "document.fill")
                    }
                }
                .onDelete(perform: withAnimation { vm.deleteFiles })
                
                if !vm.importedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(vm.importedImages) { image in
                                Image(decorative: image.thumbnail, scale: 1)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(.rect(corners: .concentric(minimum: 15), isUniform: true))
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            withAnimation {
                                                vm.deleteImage(id: image.id)
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(.white, .black.opacity(0.5))
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .listRowInsets(.init())
                }
                
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
