//
//  CategoryRowView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 13/03/2026.
//

import SwiftUI

struct CategoryRowView: View {
    @ObservedObject var category: CategoryEntity
    
    var body: some View {
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
    }
}

#Preview {
    let persistence = PersistenceController.preview
    CategoryRowView(category: CategoryEntity(context: persistence.viewContext))
}
