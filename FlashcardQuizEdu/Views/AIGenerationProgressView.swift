//
//  AIGenerationProgressView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 03/04/2026.
//

import SwiftUI

struct AIGenerationProgressView: View {
    @State private var vm: AIGenerationProgressViewModel
    
    init(viewModel: AIGenerationProgressViewModel) {
        self.vm = viewModel
    }
    
    var progressValue: Double {
        switch vm.state {
        case .extracting: 1.0
        case .generating: 2.0
        case .result(_): 3.0
        case .error(_): 0.0
        }
    }
    
    var progressLabel: String {
        switch vm.state {
        case .extracting:
            "Extracting..."
        case .generating:
            "Generating..."
        case .result(_):
            "Complete!"
        case .error(let error):
            "There was an error: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .extracting:
                ProgressView(value: progressValue, total: 3) {
                    Text(progressLabel)
                }
                .padding()
            case .generating:
                ProgressView(value: progressValue, total: 3) {
                    Text(progressLabel)
                }
                .padding()
            case .result(let flashcards):
                List(flashcards, id: \.question) { card in
                    VStack {
                        Text(card.question)
                        Text(card.answer)
                    }
                }
            case .error(let error):
                Text("There was an error: \(error.localizedDescription)")
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .task {
            await vm.perform()
        }
    }
}

#Preview {
    AIGenerationProgressView(viewModel: AIGenerationProgressViewModel(importedDocuments: [], importedImages: [], pdfExtractor: PDFDocumentExtractor(), imageExtractor: ImageExtractor()))
}
