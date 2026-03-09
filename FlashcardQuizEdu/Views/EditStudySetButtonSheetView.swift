//
//  NewStudySetButtonSheetView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 20/02/2026.
//

import SwiftUI

struct EditStudySetButtonSheetView: View {
    @State private var showingSheet = false
    
    let category: CategoryEntity?
    
    var body: some View {
        Button("Nowy zestaw", systemImage: "plus", role: .confirm) {
            showingSheet = true
        }
        .tint(category?.accentColor.value)
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                EditStudySetView(viewModel: EditStudySetViewModel(creatingIn: category?.objectID))
            }
        }
    }
}
