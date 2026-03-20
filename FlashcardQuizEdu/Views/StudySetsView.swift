//
//  CategoryDetailsView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 24/01/2026.
//

import SwiftUI

struct StudySetsView: View {
    @State private var vm: StudySetsViewModel
    @State private var editingViewModel: EditStudySetViewModel?
    @State private var activeAlert: ActiveAlert?
    
    private let tagAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    init(viewModel: StudySetsViewModel) {
        self.vm = viewModel
    }
    
    var body: some View {
        List {
            Section {
                if vm.studySets.isEmpty {
                    ContentUnavailableView("Brak wyników", systemImage: "rectangle.stack.slash", description: Text("Dodaj nowy zestaw, aby rozpocząć."))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(vm.studySets) { studySet in
                        StudySetRowView(studySet: studySet)
                            .swipeEditDeleteActions {
                                withAnimation {
                                    onDelete(of: studySet)
                                }
                            } onEdit: {
                                withAnimation {
                                    openEditSheet(for: studySet)
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle(vm.title)
        .toolbar {
            ToolbarItem {
                SortingPicker(optionSelection: $vm.sortOption, directionSelection: $vm.sortDirection, directionLabel: vm.directionLabel)
                .tint(.none)
            }
            ToolbarSpacer(.fixed)
            ToolbarItem {
                EditStudySetButtonSheetView(category: vm.category)
            }
        }
        .safeAreaInset(edge: .top) {
            if !vm.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        TagButton(name: "Wszystkie", isSelected: vm.selectedTags.isEmpty) {
                            withAnimation(tagAnimation) {
                                vm.clearTags()
                            }
                        }
                        
                        ForEach(vm.allTags, id: \.self) { tag in
                            TagButton(name: tag.wrappedName, isSelected: vm.selectedTags.contains(tag)) {
                                withAnimation(tagAnimation) {
                                    vm.toggleTag(tag)
                                }
                            }
                        }
                    }
                    .padding(.leading)
                }
            }
        }
        .sheet(item: $editingViewModel) { vm in
            NavigationStack {
                EditStudySetView(viewModel: vm)
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .delete(let studySet):
                return Alert(
                    title: Text("Usunąć \(studySet.wrappedName)?"),
                    message: Text("Spowoduje to usunięcie całej zawartości tego zestawu."),
                    primaryButton: .destructive(Text("Usuń")) {
                        withAnimation {
                            vm.delete(studySet)
                        }
                    },
                    secondaryButton: .cancel(Text("Anuluj"))
                )

            case .editError(let error):
                return Alert(
                    title: Text(error.errorDescription ?? "Błąd"),
                    message: Text(error.failureReason ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func openEditSheet(for studySet: StudySetEntity) {
        do {
            editingViewModel = try EditStudySetViewModel(editing: studySet.objectID)
        } catch let error as EditStudySetError {
            activeAlert = .editError(error)
        } catch {
            assertionFailure("Unexpected error: \(error)")
        }
    }
    
    private func onDelete(of studySet: StudySetEntity) {
        activeAlert = .delete(studySet)
    }
    
    private enum ActiveAlert: Identifiable {
        case delete(StudySetEntity)
        case editError(EditStudySetError)
        
        var id: String {
            switch self {
            case .delete(let set): "delete-\(set.objectID.uriRepresentation().absoluteString)"
            case .editError(let error): "error-\(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    let persistence = PersistenceController.preview
    let category = try! persistence.viewContext.fetch(CategoryEntity.fetchRequest()).first!
    let vm = StudySetsViewModel(category: category, persistence: persistence)
    
    NavigationStack {
        StudySetsView(viewModel: vm)
            .tint(.orange)
    }
}
