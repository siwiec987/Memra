//
//  StudyView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/01/2026.
//

import SwiftUI

struct StudyView: View {
    @State private var vm: StudyViewModel
    @State private var editingViewModel: EditCategoryViewModel?
    @State private var activeAlert: ActiveAlert?

    init(viewModel: StudyViewModel = StudyViewModel()) {
        self.vm = viewModel
    }

    var body: some View {
        List {
            ForEach(vm.categories) { category in
                CategoryRowView(category: category)
                    .swipeEditDeleteActions {
                        onDelete(of: category)
                    } onEdit: {
                        openEditSheet(for: category)
                    }
            }
        }
        .navigationTitle("Kategorie")
        .navigationDestination(for: CategoryEntity.self) { category in
            let vm = StudySetsViewModel(category: category)
            StudySetsView(viewModel: vm)
                .tint(category.accentColor.value)
        }
        .toolbar {
            ToolbarItem {
                SortingPicker(
                    optionSelection: $vm.sortOption,
                    directionSelection: $vm.sortDirection,
                    directionLabel: vm.directionLabel
                )
            }
            ToolbarItem {
                EditStudySetButtonSheetView(category: nil)
            }
        }
        .sheet(item: $editingViewModel) { vm in
            NavigationStack {
                EditCategoryView(viewModel: vm)
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .delete(let category):
                return Alert(
                    title: Text("Usunąć \(category.wrappedName)?"),
                    message: Text("Spowoduje to usunięcie całej zawartości tej kategorii."),
                    primaryButton: .destructive(Text("Usuń")) {
                        withAnimation {
                            vm.delete(category)
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
    
    private func openEditSheet(for category: CategoryEntity) {
        do {
            editingViewModel = try EditCategoryViewModel(editing: category.objectID)
        } catch let error as EditCategoryError {
            activeAlert = .editError(error)
        } catch {
            assertionFailure("Unexpected error: \(error)")
        }
    }
    
    private func onDelete(of category: CategoryEntity) {
        activeAlert = .delete(category)
    }
    
    private enum ActiveAlert: Identifiable {
        case delete(CategoryEntity)
        case editError(EditCategoryError)
        
        var id: String {
            switch self {
            case .delete(let category): "delete-\(category.objectID.uriRepresentation().absoluteString)"
            case .editError(let error): "error-\(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    NavigationStack {
        StudyView()
    }
}
