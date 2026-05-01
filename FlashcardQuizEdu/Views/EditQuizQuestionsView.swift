//
//  EditQuizQuestionsView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 01/05/2026.
//

import CoreData
import SwiftUI


struct EditQuizQuestionsView: View {
    let title: String
    let quiz: [QuizQuestionEntity]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(quiz) { question in
                EditQuizQuestionView(question: question)
            }
            .onDelete(perform: onDelete)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
        .listRowSpacing(10)
    }
    
    private struct EditQuizQuestionView: View {
        @ObservedObject var question: QuizQuestionEntity
        
        private var answers: [QuizAnswerEntity] {
            question.answerSet.sorted { $0.wrappedText < $1.wrappedText }
        }
        
        var body: some View {
            VStack {
                TextField(
                    "Pytanie",
                    text: Binding(
                        get: { question.wrappedText },
                        set: { question.wrappedText = $0 }
                    ),
                    axis: .vertical
                )
                
                Divider()
                
                ForEach(answers) { answer in
                    EditAnswerRowView(answer: answer)
                }
            }
        }
    }
    
    private struct EditAnswerRowView: View {
        @ObservedObject var answer: QuizAnswerEntity
        
        var body: some View {
            HStack(spacing: 15) {
                TextField(
                    "Odpowiedź",
                    text: Binding(
                        get: { answer.wrappedText },
                        set: { answer.wrappedText = $0 }
                    ),
                    axis: .vertical
                )

                Spacer()
                
                Button("Poprawna odpowiedź?", systemImage: answer.isCorrect ? "checkmark.circle.fill" : "circle", action: toggleAnswer)
                    .font(.title2)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .contentTransition(.symbolEffect(.replace, options: .speed(1.5)))
            }
        }
        
        private func toggleAnswer() {
            withAnimation{ answer.isCorrect.toggle() }
        }
    }
}

#Preview {
    let persistence = PersistenceController.preview
    let request = StudySetEntity.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "flashcardCount", ascending: false)]
    request.fetchLimit = 1
    let studySet = try! persistence.viewContext.fetch(request).first!
    let vm = try! EditStudySetViewModel(persistence: persistence, editing: studySet.objectID)
    
    return NavigationStack {
        EditStudySetView(viewModel: vm)
    }
}

//private struct QuizEditorView: View {
//let vm: EditStudySetViewModel
//
//var body: some View {
//List {
//ForEach(vm.quizSorted) { question in
//Section {
//TextField(
//    "Pytanie",
//    text: Binding(
//        get: { question.wrappedText },
//        set: { question.wrappedText = $0 }
//    ),
//    axis: .vertical
//)
//
//ForEach(vm.answersSorted(for: question)) { answer in
//    HStack(alignment: .top, spacing: 12) {
//        Button {
//            answer.isCorrect.toggle()
//        } label: {
//            Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
//                .foregroundStyle(answer.isCorrect ? .green : .secondary)
//        }
//        .buttonStyle(.plain)
//
//        TextField(
//            "Odpowiedź",
//            text: Binding(
//                get: { answer.wrappedText },
//                set: { answer.wrappedText = $0 }
//            ),
//            axis: .vertical
//        )
//
//        Button(role: .destructive) {
//            vm.deleteAnswer(answer, from: question)
//        } label: {
//            Image(systemName: "trash")
//        }
//        .buttonStyle(.borderless)
//    }
//}
//
//Button {
//    vm.addAnswer(to: question)
//} label: {
//    Label("Dodaj odpowiedź", systemImage: "plus.circle")
//}
//
//Button("Usuń pytanie", role: .destructive) {
//    vm.deleteQuizQuestion(question)
//}
//} footer: {
//Text("Zaznacz kółkiem poprawne odpowiedzi.")
//}
//}
//
//Button {
//vm.addQuizQuestion()
//} label: {
//Label("Dodaj pytanie", systemImage: "plus.circle.fill")
//}
//}
//.navigationTitle("Quiz")
//}
//}
