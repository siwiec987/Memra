//
//  AIGenerationSetupView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/03/2026.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct AIGenerationSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm: AIGenerationSetupViewModel
    @State private var showingImporter = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    @State private var failedFiles: [FailedImport] = [] // couldn't animate without
    let sectionSpacing: CGFloat = 15
    
    @State private var picker = "B"
    @State private var selectedLanguage = "en"
    @State private var generateFlashcards = true
    @State private var generateQuiz = false
    
    var contentDescription: String {
        if generateFlashcards && !generateQuiz {
            return "Dla tego zestawu zostaną wygenerowane tylko fiszki."
        }
        if generateQuiz && !generateFlashcards {
            return "Dla tego zestawu zostanie wygenerowany tylko quiz."
        }
        if generateQuiz && generateFlashcards {
            return "Dla tego zestawu zostaną wygenerowane fiszki oraz quiz."
        }
        
        return "Wybierz co chcesz wygenerować."
    }
    
    init(viewModel: AIGenerationSetupViewModel) {
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
            
            Section {
                HStack {
                    Button { generateFlashcards.toggle() } label: {
                        ConcentricRectangle()
                            .fill(generateFlashcards ? .primary : .secondary)
                            .overlay {
                                Text("Fiszki")
                                    .font(.title3).bold()
                                    .foregroundStyle(.white)
                            }
                    }

                    Button { generateQuiz.toggle() } label: {
                        ConcentricRectangle()
                            .fill(generateQuiz ? .primary : .secondary)
                            .overlay {
                                Text("Quiz")
                                    .font(.title3).bold()
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .buttonStyle(.borderless)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
            } header: {
                Text("DOSTOSUJ")
            } footer: {
                Text(contentDescription)
            }
            
            Section("Zakres materiału") {
                Picker("Zakres materiału", selection: $picker) {
                    Text("tylko najważniejsze").tag("A")
                    Text("automatycznie").tag("B")
                    Text("szczegółowo").tag("C")
                    Text("własne").tag("D")
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            if picker == "D" {
                Section("MAKSYMALNA ILOŚĆ FISZEK") {
                    RoundingSlider(value: $vm.flashcardCount, range: 2...50)
                }
                
                Section("MAKSYMALNA ILOŚĆ PYTAŃ") {
                    RoundingSlider(value: $vm.questionCount, range: 2...50)
                }
            }
            
            Section {
                Picker("Język", selection: $selectedLanguage) {
                    ForEach(Bundle.main.localizations, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
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
                NavigationLink {
                    let imageExtractor = ImageExtractor()
                    let config = FlashcardGenerationConfiguration.default
                    let chunker = DocumentChunker(configuration: config)
                    AIGenerationProgressView(
                        viewModel: AIGenerationProgressViewModel(
                            importedDocuments: vm.importedDocuments,
                            importedImages: vm.importedImages,
                            pdfExtractor: PDFDocumentExtractor(imageExtractor: imageExtractor),
                            imageExtractor: imageExtractor,
                            flashcardGenerator: FlashcardGenerator(configuration: config, chunker: chunker)
                        )
                    )
                    .navigationBarBackButtonHidden()
                } label: {
                    HStack {
                        Image(systemName: "sparkles.2")
                        Text("Generuj")
                    }
                    .padding()
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
    NavigationStack {
        AIGenerationSetupView(
            viewModel: AIGenerationSetupViewModel()
        )
    }
}
