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
    @State private var generatedStudySet: GeneratedStudySet?
    
    var body: some View {
        ZStack {
            if phase == .setup {
                AIGenerationSetupView(
                    viewModel: AIGenerationSetupViewModel(),
                    onGenerate: createProgressVM
                )
            }
            
            if let generatedStudySet, phase == .done {
                EditStudySetView(
                    viewModel: EditStudySetViewModel(
                        creatingIn: nil,
                        from: generatedStudySet
                    )
                )
                .toolbarVisibility(.hidden, for: .bottomBar)
            }
            
            if let progressVM, phase == .generating {
                AIGenerationProgressView(viewModel: progressVM)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale))
                .toolbarVisibility(.hidden, for: .bottomBar)
            }
            
            
        }
        .onChange(of: progressVM?.state, handleProgressStateChange)
    }
    
    private func handleProgressStateChange() {
        guard let progressVMUnwrapped = progressVM, progressVMUnwrapped.state == .completed else { return }
            withAnimation {
                generatedStudySet = progressVMUnwrapped.generatedStudySet
                phase = .done
                progressVM = nil
            }
    }
    
    private func createProgressVM(documents: [ImportedFile], images: [ImportedImage], generateFlashcards: Bool, quizConfiguration: StudySetGenerator.QuizConfiguration?) {
        let imageExtractor = ImageExtractor()
        withAnimation {
            generatedStudySet = nil
            progressVM = AIGenerationProgressViewModel(
                importedDocuments: documents,
                importedImages: images,
                pdfExtractor: PDFDocumentExtractor(imageExtractor: imageExtractor),
                imageExtractor: imageExtractor,
                studySetGenerator: StudySetGenerator(generateFlashcards: generateFlashcards, quizConfiguration: quizConfiguration)
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
