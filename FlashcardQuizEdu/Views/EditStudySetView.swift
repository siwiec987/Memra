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
                HStack {
                    TextField("Nowy tag", text: $vm.newTagName)
                        .onSubmit {
                            withAnimation(tagAnimation, vm.addTag)
                        }
                    
                    Button {
                        withAnimation(tagAnimation) {
                            vm.addTag()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .symbolVariant(.circle.fill)
                    }
                    .tint(.green)
                    .disabled(vm.newTagNameTrimmed.isEmpty)
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
    
    func addTag() {
        
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    let persistence = PersistenceController.preview
    let studySetService = StudySetService(manager: persistence)
    let studySet = studySetService.fetchAll(sortedBy: .tagCount, direction: .descending).first!
    
    let vm = EditStudySetViewModel(persistence: persistence, creatingIn: nil)
    
    NavigationStack {
        Circle().sheet(isPresented: $isPresented) {
            NavigationStack {
                EditStudySetView(viewModel: vm)
            }
        }
    }
}
