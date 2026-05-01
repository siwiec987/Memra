//
//  EditFlashcardsView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 01/05/2026.
//

import CoreData
import SwiftUI

struct EditFlashcardsView: View {
    @FocusState private var focusedField: FocusedField?
    let title: String
    let flashcards: [FlashcardEntity]
    let onDelete: (IndexSet) -> Void
    let onAdd: (String, String) -> Void
    
    var body: some View {
        List {
            ForEach(flashcards) { flashcard in
                EditFlashcardView(flashcard: flashcard, focusedField: $focusedField, onAnswerSubmit: focusNext)
            }
            .onDelete(perform: onDelete)
            
            NewFlashcardView(focusedField: $focusedField, action: onAdd)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
        .listRowSpacing(10)
    }
    
    private func focusNext(after id: NSManagedObjectID) {
        guard let currentIndex = flashcards.firstIndex(where: { $0.objectID == id }) else {
            focusedField = .newQuestion
            return
        }
        
        let nextIndex = flashcards.index(after: currentIndex)
        guard flashcards.indices.contains(nextIndex) else {
            focusedField = .newQuestion
            return
        }
        
        focusedField = .question(flashcards[nextIndex].objectID)
    }
    
    private enum FocusedField: Hashable {
        case question(NSManagedObjectID)
        case answer(NSManagedObjectID)
        case newQuestion
        case newAnswer
    }

    private struct EditFlashcardView: View {
        @ObservedObject var flashcard: FlashcardEntity
        @FocusState.Binding var focusedField: FocusedField?
        let onAnswerSubmit: (NSManagedObjectID) -> Void
        
        var body: some View {
            VStack {
                TextField(
                    "Pytanie",
                    text: Binding(
                        get: { flashcard.wrappedQuestion },
                        set: { flashcard.wrappedQuestion = $0 }
                    ),
                    axis: .vertical
                )
                .onSubmit { focusedField = .answer(flashcard.objectID) }
                .focused($focusedField, equals: .question(flashcard.objectID))
                
                Divider()
                
                TextField(
                    "Odpowiedź",
                    text: Binding(
                        get: { flashcard.wrappedAnswer },
                        set: { flashcard.wrappedAnswer = $0 }
                    ),
                    axis: .vertical
                )
                .onSubmit { onAnswerSubmit(flashcard.objectID) }
                .focused($focusedField, equals: .answer(flashcard.objectID))
            }
        }
    }
    
    private struct NewFlashcardView: View {
        @State private var question = ""
        @State private var answer = ""
        @FocusState.Binding var focusedField: FocusedField?
        let action: (String, String) -> Void
        
        var isSubmitDisabled: Bool {
            question.trimmed().isEmpty ||
            answer.trimmed().isEmpty
        }
        
        var body: some View {
            HStack(spacing: 15) {
                Button("Dodaj fiszkę", systemImage: "plus.circle.fill", action: onSubmit)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .tint(.green)
                    .disabled(isSubmitDisabled)
                
                VStack {
                    TextField("Pytanie", text: $question, axis: .vertical)
                        .onSubmit { focusedField = .newAnswer }
                        .focused($focusedField, equals: .newQuestion)
                    
                    Divider()
                    
                    TextField("Odpowiedź", text: $answer, axis: .vertical)
                        .onSubmit(onSubmit)
                        .focused($focusedField, equals: .newAnswer)
                }
            }
        }
        
        private func onSubmit() {
            if !isSubmitDisabled {
                action(question, answer)
                question = ""
                answer = ""
            }
            focusedField = .newQuestion
        }
    }
}
