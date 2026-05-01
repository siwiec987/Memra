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
    
    let onGenerate: ([ImportedFile], [ImportedImage], Bool, StudySetGenerator.QuizConfiguration?) -> Void
    
    @State private var vm: AIGenerationSetupViewModel
    @State private var showingImporter = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    @State private var failedFiles: [FailedImport] = [] // couldn't animate without
    let sectionSpacing: CGFloat = 15
    
//    @State private var picker = "B" // implement later
    @State private var selectedLanguage = "en"
    
    init(viewModel: AIGenerationSetupViewModel, onGenerate: @escaping ([ImportedFile], [ImportedImage], Bool, StudySetGenerator.QuizConfiguration?) -> Void) {
        self.vm = viewModel
        self.onGenerate = onGenerate
    }
    
    var body: some View {
        Form {
            Section("DODAJ MATERIAŁY") {
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
                    Button { vm.generateFlashcards.toggle() } label: {
                        ConcentricRectangle()
                            .fill(vm.generateFlashcards ? .primary : .secondary)
                            .overlay {
                                Text("Fiszki")
                                    .font(.title3).bold()
                                    .foregroundStyle(.white)
                            }
                    }

                    Button { vm.generateQuiz.toggle() } label: {
                        ConcentricRectangle()
                            .fill(vm.generateQuiz ? .primary : .secondary)
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
                Text("CO WYGENEROWAĆ")
            } footer: {
                Text(vm.contentDescription)
            }
            
//            Section("Zakres materiału") {
//                Picker("Zakres materiału", selection: $picker) {
//                    Text("tylko najważniejsze").tag("A")
//                    Text("automatycznie").tag("B")
//                    Text("szczegółowo").tag("C")
//                    Text("własne").tag("D")
//                }
//                .pickerStyle(.inline)
//                .labelsHidden()
//            }
                
            if vm.generateQuiz {
                Section("USTAWIENIA QUIZU") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Liczba odpowiedzi na pytanie")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(Int(vm.quizAnswersPerQuestion))")
                                .bold()
                                .contentTransition(.numericText(value: vm.quizAnswersPerQuestion))
                                .animation(.default, value: vm.quizAnswersPerQuestion)
                        }
                        .foregroundStyle(.secondary)

                        Slider(value: $vm.quizAnswersPerQuestion, in: 2...6, step: 1) {
                            Text("Liczba odpowiedzi na pytanie")
                        }
                    }
                    
                    Toggle(isOn: $vm.quizAllowsMultipleAnswers) {
                        Text("Wiele poprawnych odpowiedzi")
                    }
                }
            }
            
            Section("JĘZYK GENEROWANIA") {
                Picker("Język", selection: $selectedLanguage) {
                    ForEach(Bundle.main.localizations, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
            }

            if let foundationModelsUnavailableMessage = vm.foundationModelsUnavailableMessage {
                Section {
                    Label(foundationModelsUnavailableMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                } header: {
                    Text("DOSTĘPNOŚĆ APPLE INTELLIGENCE")
                } footer: {
                    Text("Generowanie wymaga dostępnego modelu Foundation Models na tym urządzeniu.")
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
                Button {
                    onGenerate(vm.importedDocuments, vm.importedImages, vm.generateFlashcards, vm.quizConfiguration)
                } label: {
                    HStack {
                        Image(systemName: "sparkles.2")
                        Text("Generuj")
                    }
                    .padding(.horizontal)
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
        .tint(.red)
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
            viewModel: AIGenerationSetupViewModel(),
            onGenerate: { _,_,_,_ in}
        )
    }
}
