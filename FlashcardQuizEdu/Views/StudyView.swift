//
//  StudyView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/01/2026.
//

import SwiftUI

struct StudyView: View {
    @State private var vm: StudyViewModel

    init(viewModel: StudyViewModel = StudyViewModel()) {
        self.vm = viewModel
    }

    var body: some View {
        List {
            ForEach(vm.categories) { category in
                NavigationLink(value: category) {
                    Label {
                        VStack(alignment: .leading) {
                            Text(category.wrappedName)
                                .font(.headline)
                            Text("Zestawy: \(category.studySetCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: category.wrappedSystemIcon)
                            .symbolVariant(.fill)
                            .foregroundStyle(category.accentColor.value)
                    }
                }
                .swipeEditDeleteActions {
                    
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
    }
    
    private func openEditSheet(for category: CategoryEntity) {
        
    }
    
    private func onDelete(of category: CategoryEntity) {
        
    }
}

#Preview {
    NavigationStack {
        StudyView()
    }
}
