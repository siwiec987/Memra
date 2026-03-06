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
                //kategorie -> sety -> itd
                NavigationLink(value: category) {
                    Label {
                        Text(category.wrappedName)
                    } icon: {
                        Image(systemName: category.wrappedSystemIcon)
                            .foregroundStyle(category.accentColor.value)
                    }
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
                EditSetButtonSheetView(category: nil)
            }
        }
    }
}

#Preview {
    let manager = PersistenceController.preview
    let service = CategoryService(manager: manager)
    let vm = StudyViewModel(categoryService: service)
    
    NavigationStack {
        StudyView(viewModel: vm)
    }
}
