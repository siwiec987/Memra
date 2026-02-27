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
        List(vm.categories) { category in
            //kategorie -> sety -> itd
            NavigationLink(value: category) {
                HStack {
                    Image(systemName: category.wrappedSystemIcon)
//                        .foregroundStyle(category.color)
                        .frame(width: 50)
                    
                    Text(category.wrappedName)
                }
            }
        }
        .navigationDestination(for: CategoryEntity.self) { category in
            let vm = StudySetsViewModel(category: category)
            StudySetsView(viewModel: vm)
        }
        .toolbar {
            ToolbarItem {
                EditSetButtonSheetView()
            }
        }
    }
}

#Preview {
    let manager = CoreDataManager.preview
    let service = CategoryService(manager: manager)
    let vm = StudyViewModel(categoryService: service)
    
    NavigationStack {
        StudyView(viewModel: vm)
    }
}
