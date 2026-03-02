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
    
    // TODO: Alert o zmianach niezapisanych lub o odrzuceniu nowego zestawu jak w przypomnieniach applowych
    // TODO: Ogarnij wyświetlanie tych tagów, bo to jest jakieś nieporozumienie co się tu dzieje
    // TODO: Po dodaniu nowej kategorii vm.selectedCategory powinno zostać zaktualizowane
    
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
                        Label(category.wrappedName, systemImage: category.wrappedSystemIcon).tag(category)
                    }
                }
                
                NavigationLink("Nowa kategoria") {
                    EditCategoryView { newCategory in
                        vm.selectedCategory = newCategory
                    }
                        .tint(.none)
                }
            }
            
            Section {
                HStack {
                    TextField("Nowy tag", text: $vm.newTagName)
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .symbolVariant(.circle.fill)
                            .tint(.green)
                    }
                    .disabled(vm.newTagName.isEmpty)
                }
                
                ForEach(vm.selectedTags) { tag in
                    Button {
                        vm.toggleTag(tag)
                    } label: {
                        Text("wybrany " + tag.wrappedName)
                    }
                }
                
                ForEach(vm.initialTags) { tag in
                    Button {
                        vm.toggleTag(tag)
                    } label: {
                        Text("istniejący " + tag.wrappedName)
                    }
                }
                
                ForEach(vm.remainingTags) { tag in
                    Button {
                        vm.toggleTag(tag)
                    } label: {
                        Text(tag.wrappedName)
                    }
                }
            }
            .buttonStyle(.plain)
        }
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
                    showingConfirmationDialog = true
//                    dismiss()
                }
                .confirmationDialog("Odrzucić zmiany?", isPresented: $showingConfirmationDialog, titleVisibility: .visible) {
                    Button("Odrzuć", role: .destructive) {
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled(vm.isSaveDisabled)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    let manager = CoreDataManager.preview
    let categoryService = CategoryService(manager: manager)
    let tagService = TagService(manager: manager)
    let studySetService = StudySetService(manager: manager)
    let studySet = studySetService.fetchAll(sortedBy: .tagCount, direction: .descending).first!
    let vm = EditSetViewModel(categoryService: categoryService, tagService: tagService, studySetService: studySetService, selectedStudySet: studySet)
    
    NavigationStack {
        Circle().sheet(isPresented: $isPresented) {
            NavigationStack {
                EditSetView(viewModel: vm)
            }
        }
    }
}
