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
    
    init(viewModel: EditSetViewModel = EditSetViewModel()) {
        self.vm = viewModel
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Nazwa", text: $vm.name)
            }
            
            Section {
                Picker("Kategoria", selection: $vm.selectedCategory) {
                    ForEach(vm.categories) { category in
                        if let name = category.name, let icon = category.systemIcon {
                            Label(name, systemImage: icon).tag(category)
                        }
                    }
                }
                
                NavigationLink("Nowa kategoria") {
                    EditCategoryView()
                        .tint(.none)
                }
            }
            
            Section {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(vm.tags) { tag in
                            if let name = tag.name {
                                Button(name) {
                                    
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Nowy zestaw")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
//    let manager = CoreDataManager.preview
//    let categoryService = CategoryService(manager: manager)
//    let tagService = TagService(manager: manager)
    
    NavigationStack {
        EditSetView(viewModel: EditSetViewModel())
    }
}
