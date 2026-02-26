//
//  CategoriesGridView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 22/01/2026.
//

import SwiftUI

struct CategoriesGridView: View {
    @Binding var selectedTab: AppTab
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 10)
    ]
    
    private let categoryLimit = 6
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Kategorie")
                    .font(.headline)
                
                Button("Zobacz wszystkie") {
                    selectedTab = .study
                }
                    .font(.caption)
            }
            
            LazyVGrid(columns: columns) {
//                ForEach(categories.prefix(categoryLimit)) { category in
//                    categoryBox(for: category)
//                }
            }
            .containerShape(.rect(cornerRadius: 15))
        }
    }
    
    func categoryBox(for category: Category) -> some View {
        VStack {
//            Image(systemName: category.systemIcon)
//                .font(.largeTitle)
//                .foregroundStyle(category.color)
            
//            Text(category.name)
//                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.secondary.opacity(0.15))
        .clipShape(.containerRelative)
    }
}

#Preview {
//    let manager = CoreDataManager.preview
//    do {
//        let previewer = try Previewer()
//        
//        return CategoriesGridView(selectedTab: .constant(.home))
//            .padding()
//            .modelContainer(previewer.container)
//    } catch {
//        return Text(error.localizedDescription)
//    }
}
