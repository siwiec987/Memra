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
            
            Section {
                ForEach(vm.importedFiles) { file in
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
                .onDelete(perform: vm.deleteFiles)
                
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
                .font(.title2)
                .fontWeight(.semibold)
                .monospaced()
                .disabled(vm.importedFiles.isEmpty || (vm.flashcardCountRounded == 0 && vm.questionCountRounded == 0))
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [
                .pdf
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
    
    private struct RoundingSlider: View {
        @Binding var value: Double
        let range: ClosedRange<Double>
        let onEditingChanged: () -> Void
        
        private var valueRounded: Double {
            value.rounded()
        }
        
        init(value: Binding<Double>, range: ClosedRange<Double>, onEditingChanged: @escaping () -> Void = {}) {
            self._value = value
            self.range = range
            self.onEditingChanged = onEditingChanged
        }
        
        var body: some View {
            HStack {
                Slider(value: $value, in: range) {
                    Text("Ilość pytań")
                } onEditingChanged: { _ in
                    value = valueRounded
                    onEditingChanged()
                }

                Text(String(format: "%02d", Int(valueRounded)))
                    .monospaced()
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(valueRounded == 0 ? .secondary : .primary)
            }
        }
    }
}

#Preview {
    GenerateWithAIView(viewModel: GenerateWithAIViewModel())
}
