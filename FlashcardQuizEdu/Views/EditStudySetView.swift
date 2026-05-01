//
//  EditStudySetView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 20/02/2026.
//

import SwiftUI

struct EditStudySetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: EditStudySetViewModel
    @State private var showingConfirmationDialog = false
    
    private let tagAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    init(viewModel: EditStudySetViewModel) {
        self.vm = viewModel
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Nazwa", text: $vm.studySetName)
            }
            
            Section {
                Picker("Kategoria", selection: $vm.selectedCategory) {
                    ForEach(vm.categories) { category in
                        Label(category.wrappedName, systemImage: category.wrappedSystemIcon)
                            .symbolVariant(.fill)
                            .tint(category.accentColor.value)
                            .tag(Optional(category))
                    }
                }
                .id(vm.selectedCategory?.objectID)
                
                NavigationLink("Nowa kategoria") {
                    EditCategoryView() { newCategory in
                        vm.newCategory(newCategory)
                    }
                }
            }
            
            Section {
                EditorNavigationRow(
                    title: "Fiszki",
                    systemImage: "square.stack.3d.up.fill",
                    count: vm.flashcards.count
                ) {
                    EditFlashcardsView(
                        title: "Fiszki",
                        flashcards: vm.flashcards,
                        onDelete: vm.deleteFlashcards,
                        onAdd: vm.newFlashcard
                    )
                }

                EditorNavigationRow(
                    title: "Quiz",
                    systemImage: "checklist",
                    count: vm.quiz.count
                ) {
                    EditQuizQuestionsView(
                        title: "Quiz",
                        quiz: vm.quiz,
                        onDelete: {_ in}
                    )
//                    .tint(vm.selectedCategory?.accentColor.value)

                }
            }
            
            Section {
                HStack(spacing: 15) {
                    Button("Dodaj tag", systemImage: "plus.circle.fill", action: addTag)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .tint(.green)
                    .disabled(vm.newTagNameTrimmed.isEmpty)
                    
                    TextField("Nowy tag", text: $vm.newTagName)
                        .onSubmit(addTag)
                }
                
                if !vm.tags.isEmpty {
                    FlowLayout {
                        ForEach(vm.tagsSorted) { tag in
                            TagButton(name: tag.wrappedName, isSelected: vm.selectedTagIDs.contains(tag.objectID)) {
                                withAnimation {
                                    vm.toggleTag(tag)
                                }
                            }
                        }
                    }
                }
            }
        }
        .tint(vm.selectedCategory?.accentColor.value)
        .navigationTitle(vm.isEditing ? "Edytuj zestaw" : "Nowy zestaw")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    vm.save()
                    dismiss()
                }
                .disabled(vm.isSaveDisabled)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) {
                    if vm.hasUnsavedChanges {
                        showingConfirmationDialog = true
                    } else {
                        dismiss()
                    }
                }
                .confirmationDialog("Czy na pewno chcesz odrzucić zmiany?", isPresented: $showingConfirmationDialog, titleVisibility: .visible) {
                    Button("Odrzuć", role: .destructive) {
                        dismiss()
                    }
                }
            }
        }
        .tint(.none)
        .interactiveDismissDisabled(vm.hasUnsavedChanges)
    }
    
    private func addTag() {
        withAnimation(tagAnimation, vm.addTag)
    }
    
    private struct EditorNavigationRow<Destination: View>: View {
        let title: String
        let systemImage: String
        let count: Int
        let destination: () -> Destination
        
        var body: some View {
            NavigationLink {
                destination()
            } label: {
                Label {
                    HStack(alignment: .center) {
                        Text(title)
                        Spacer()
                        Text("\(count)")
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: systemImage)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    let persistence = PersistenceController.preview
    let request = StudySetEntity.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "flashcardCount", ascending: false)]
    request.fetchLimit = 1
    let studySet = try! persistence.viewContext.fetch(request).first!
    let vm = try! EditStudySetViewModel(persistence: persistence, editing: studySet.objectID)
    
    return NavigationStack {
        Circle().sheet(isPresented: $isPresented) {
            NavigationStack {
                EditStudySetView(viewModel: vm)
            }
        }
    }
}
