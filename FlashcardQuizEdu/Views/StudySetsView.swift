//
//  CategoryDetailsView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 24/01/2026.
//

import SwiftUI

struct StudySetsView: View {
    @State private var vm: StudySetsViewModel
    
    init(viewModel: StudySetsViewModel) {
        self.vm = viewModel
    }
    
    private let tagAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    var body: some View {
        List {
            Section {
                if vm.studySets.isEmpty && !vm.query.isEmpty {
                    ContentUnavailableView("Brak wyników", systemImage: "magnifyingglass", description: Text("Sprawdź pisownię lub zmień filtry"))
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                        .frame(maxHeight: .infinity)
                } else if vm.studySets.isEmpty {
                    ContentUnavailableView("Brak wyników", systemImage: "rectangle.stack.slash", description: Text("Dodaj se nowy secik mordzia"))
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(vm.studySets) { set in
                        Text(set.wrappedName)
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
                EditSetButtonSheetView()
            }
        }
        .safeAreaBar(edge: .top) {
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
        .searchable(text: $vm.query)
    }
}

#Preview {
    let manager = CoreDataManager.preview
    let studySetService = StudySetService(manager: manager)
    let categoryService = CategoryService(manager: manager)
    let category = categoryService.fetchAll().first!
    
    let vm = StudySetsViewModel(
        category: category,
        studySetService: studySetService
    )
    
    NavigationStack {
        StudySetsView(viewModel: vm)
            .tint(.orange)
    }
}
