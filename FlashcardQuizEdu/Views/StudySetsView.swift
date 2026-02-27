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
//            if !vm.tags.isEmpty {
//                Section {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            TagButton(name: "Wszystkie", isSelected: vm.selectedTags.isEmpty) {
//                                withAnimation(tagAnimation) {
//                                    vm.clearTags()
//                                }
//                            }
//                            
//                            ForEach(vm.tags, id: \.self) { tag in
//                                TagButton(name: tag.name ?? "", isSelected: vm.selectedTags.contains(tag)) {
//                                    withAnimation(tagAnimation) {
//                                        vm.toggleTag(tag)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .listRowInsets(.init())
//                    .listRowBackground(Color.clear)
//                }
//            }
            
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
//        .listSectionSpacing(20)
        .navigationTitle(vm.categoryName)
        .toolbar {
            ToolbarItem {
                SortingPicker(optionSelection: $vm.sortOption, directionSelection: $vm.sortDirection, directionLabel: vm.directionLabel(for:))
                .tint(.none)
            }
            ToolbarSpacer(.fixed)
            ToolbarItem {
                EditSetButtonSheetView()
            }
        }
        .safeAreaBar(edge: .top) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    TagButton(name: "Wszystkie", isSelected: vm.selectedTags.isEmpty) {
                        withAnimation(tagAnimation) {
                            vm.clearTags()
                        }
                    }
                    
                    ForEach(vm.tags, id: \.self) { tag in
                        TagButton(name: tag.name ?? "", isSelected: vm.selectedTags.contains(tag)) {
                            withAnimation(tagAnimation) {
                                vm.toggleTag(tag)
                            }
                        }
                    }
                }
                .padding(.leading)
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
