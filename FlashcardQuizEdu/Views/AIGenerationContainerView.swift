//
//  AIGenerationContainerView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 13/04/2026.
//

import SwiftUI

struct AIGenerationContainerView: View {
    @State private var phase: FlowPhase = .setup
    @State private var progressVM: AIGenerationProgressViewModel?
    @State private var generatedFlashcards: [GeneratedFlashcard]?
    
    var body: some View {
        ZStack {
            if phase == .setup {
                AIGenerationSetupView(
                    viewModel: AIGenerationSetupViewModel(),
                    onGenerate: createProgressVM
                )
            }
            
            if let generatedFlashcards, phase == .done {
                List(generatedFlashcards, id: \.self) { card in
                    VStack {
                        Text(card.question)
                        Text(card.answer)
                    }
                }
                .toolbarVisibility(.hidden, for: .bottomBar)
            }
            
            if let progressVM, phase == .generating {
                AIGenerationProgressView(viewModel: progressVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale))
                .toolbarVisibility(.hidden, for: .bottomBar)
                // zwraca wygenerowane rzeczy, później wołamy EditStudySet z uzupełnionymi danymi
            }
            
            
        }
        .onChange(of: progressVM?.state, handleProgressStateChange)
    }
    
    private func handleProgressStateChange() {
        guard let progressVMUnwrapped = progressVM, progressVMUnwrapped.state == .completed && !progressVMUnwrapped.generatedFlashcards.isEmpty else { return }
            withAnimation {
                generatedFlashcards = progressVMUnwrapped.generatedFlashcards
                phase = .done
                progressVM = nil
            }
    }
    
    private func createProgressVM(documents: [ImportedFile], images: [ImportedImage]) {
        let imageExtractor = ImageExtractor()
        withAnimation {
            generatedFlashcards = nil
            progressVM = AIGenerationProgressViewModel(
                importedDocuments: documents,
                importedImages: images,
                pdfExtractor: PDFDocumentExtractor(imageExtractor: imageExtractor),
                imageExtractor: imageExtractor,
                flashcardGenerator: FlashcardGenerator(configuration: .default)
            )
            
            phase = .generating
        }
    }
    
    private enum FlowPhase {
        case setup
        case generating
        case done
    }
}

#Preview {
    AIGenerationContainerView()
}
