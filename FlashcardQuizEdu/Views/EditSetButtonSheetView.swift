//
//  NewSetButtonSheetView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 20/02/2026.
//

import SwiftUI

struct EditSetButtonSheetView: View {
    @State private var showingSheet = false
    
    let category: CategoryEntity?
    
    var body: some View {
        Button(role: .confirm) {
            showingSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                EditSetView(viewModel: EditSetViewModel(selectedCategory: category))
                    .tint(.none)
            }
        }
    }
}
