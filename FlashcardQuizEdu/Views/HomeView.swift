//
//  HomeView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/01/2026.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        VStack(alignment: .leading) {
            LastStudiedView()
            
            Spacer()
                .frame(height: 20)
            
            CategoriesGridView(selectedTab: $selectedTab)
            
            Spacer()
        }
    }
}

#Preview {
    
}
