//
//  AIGenerationProgressView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 03/04/2026.
//

import SwiftUI

struct AIGenerationProgressView: View {
    private let vm: AIGenerationProgressViewModel
    @State private var points: [SIMD2<Float>] = Self.randomPoints()
    @State private var progressLabel = ""
    @State private var tryAgainButtonScale: CGFloat = 0
    @State private var shouldAnimate = true
    
    init(viewModel: AIGenerationProgressViewModel) {
        self.vm = viewModel
    }
    
    var colors: [Color] { [
        Color(red: 0.078, green: 0.106, blue: 0.302), Color(red: 0.239, green: 0.102, blue: 0.549), Color(red: 0.106, green: 0.310, blue: 0.847),
        Color(red: 0.420, green: 0.184, blue: 0.627), Color(red: 0.482, green: 0.184, blue: 0.878), Color(red: 0.0, green: 0.784, blue: 0.831),
        Color(red: 0.0, green: 0.278, blue: 0.671), Color(red: 0.102, green: 0.062, blue: 0.376), Color(red: 0.094, green: 0.125, blue: 0.361),
    ]}
    
    var body: some View {
        ZStack {
            MeshGradient(
                width: 3,
                height: 3,
                points: points,
                colors: colors
            )
            .ignoresSafeArea()
            .onAppear(perform: animateToNextState)
            
            VStack {
                Spacer()
                Spacer()
                
                Text(progressLabel)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .transition(.scale.combined(with: .slide))
                    .id(progressLabel)
                
                    Button("Try again") {
                        Task { await vm.perform() }
                    }
                    .buttonStyle(.glassProminent)
                    .scaleEffect(tryAgainButtonScale)
                
                Spacer()
            }
            .onChange(of: vm.state, handleProgressStateChange)
        }
        .task(vm.perform)
        .onDisappear { shouldAnimate = false }
    }
    
    private func handleProgressStateChange() {
        withAnimation(.bouncy) {
            progressLabel = switch vm.state {
            case .starting: "Starting..."
            case .extracting(let name): "Extracting \(name)..."
            case .generating: "Generating..."
            case .completed where vm.generatedFlashcards.isEmpty: "No results"
            case .completed: ""
            case .failed(let error):
                "There was an error: \(error.localizedDescription)"
            }
            
            tryAgainButtonScale = switch vm.state {
            case .completed where vm.generatedFlashcards.isEmpty: 1
            case .failed: 1
            default: 0
            }
        }
    }
    
    private func animateToNextState() {
        guard shouldAnimate else { return }
        
        withAnimation(.easeInOut(duration: 3)) {
            points = Self.randomPoints()
        } completion: {
            animateToNextState()
        }
    }
    
    static func randomPoints() -> [SIMD2<Float>] {
        [
            [0.0, 0.0], [Float.random(in: 0.3...0.6), 0.0], [1.0, 0.0], // top left/mid/right
            [0.0, Float.random(in: 0.3...0.6)], // mid left
            [Float.random(in: 0.2...0.8), Float.random(in: 0.2...0.8)], // mid
            [1.0, Float.random(in: 0.3...0.6)], // mid right
            [0.0, 1.0], [Float.random(in: 0.3...0.6), 1.0], [1.0, 1.0] // bottom left/mid/right
        ]
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
