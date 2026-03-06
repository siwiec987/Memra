//
//  EditSetView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 20/02/2026.
//

import SwiftUI

struct EditSetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: EditSetViewModel
    @State private var showingConfirmationDialog = false
    
    init(viewModel: EditSetViewModel = EditSetViewModel()) {
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
                        .onSubmit(vm.addTag)
                    Button {
                        vm.addTag()
                    } label: {
                        Image(systemName: "plus")
                            .symbolVariant(.circle.fill)
                    }
                    .tint(.green)
                    .disabled(vm.newTagNameTrimmed.isEmpty)
                }
                
                if !vm.tags.isEmpty {
                    FlowLayout {
                        ForEach(vm.tags) { tag in
                            TagButton(name: tag.wrappedName, isSelected: vm.selectedTagIDs.contains(tag.objectID)) {
                                vm.toggleTag(tag)
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
        .interactiveDismissDisabled(vm.hasUnsavedChanges)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    let persistence = PersistenceController.preview
    let studySetService = StudySetService(manager: persistence)
    let studySet = studySetService.fetchAll(sortedBy: .tagCount, direction: .descending).first!
    let vm = EditSetViewModel(persistence: persistence, studySetID: nil)
    
    NavigationStack {
        Circle().sheet(isPresented: $isPresented) {
            NavigationStack {
                EditSetView(viewModel: vm)
            }
        }
    }
}
