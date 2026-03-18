//
//  NewStudySetButtonSheetView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 20/02/2026.
//

import SwiftUI

struct EditStudySetButtonSheetView: View {
    @State private var showingDialog = false
    @State private var destination: Destination?
    
    let category: CategoryEntity?
    
    var body: some View {
        Button("Nowy zestaw", systemImage: "plus", role: .confirm) {
            showingDialog = true
        }
        .confirmationDialog("Nowy zestaw", isPresented: $showingDialog, titleVisibility: .visible) {
            Button("Generuj z AI") { destination = .ai }
            Button("Ręcznie") { destination = .hand }
        } message: {
            Text("Jak chcesz stworzyć ten zestaw?")
        }
        .tint(category?.accentColor.value)
        .sheet(item: $destination) { dest in
            NavigationStack {
                switch dest {
                case .ai:
                    GenerateWithAIView(viewModel: GenerateWithAIViewModel())
                        .navigationBarTitleDisplayMode(.inline)
                case .hand:
                    EditStudySetView(viewModel: EditStudySetViewModel(creatingIn: category?.objectID))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    private enum Destination: Identifiable {
        case hand
        case ai
        
        var id: Self {
            self
        }
    }
}

#Preview {
    EditStudySetButtonSheetView(category: nil)
}
