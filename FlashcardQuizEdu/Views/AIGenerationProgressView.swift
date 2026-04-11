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
        case .success(_): 3.0
        default: 0.0
        }
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle:
                ProgressView {
                    Text("Starting...")
                }
                .padding()
            case .extracting(let name):
                ProgressView(value: progressValue, total: 3) {
                    Text("Extracting \(name)...")
                }
                .padding()
            case .generating:
                ProgressView(value: progressValue, total: 3) {
                    Text("Generating...")
                }
                .padding()
            case .success(let flashcards):
                if flashcards.isEmpty {
                    Text("NO RESULTS :(:(:(:(:(:(:(:(")
                } else {
                    List(flashcards, id: \.question) { card in
                        VStack {
                            Text(card.question)
                            Text(card.answer)
                        }
                    }
                }
            case .failed(let error):
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
    let configuration = FlashcardGenerationConfiguration.default
    let chunker = DocumentChunker(configuration: configuration)

    AIGenerationProgressView(
        viewModel: AIGenerationProgressViewModel(
            importedDocuments: [],
            importedImages: [],
            pdfExtractor: PDFDocumentExtractor(),
            imageExtractor: ImageExtractor(),
            flashcardGenerator: FlashcardGenerator(
                configuration: configuration,
                chunker: chunker
            )
        )
    )
}
