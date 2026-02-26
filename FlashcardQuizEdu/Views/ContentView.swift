//
//  ContentView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 22/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Strona główna", systemImage: "house", value: .home) {
                HomeView(selectedTab: $selectedTab)
                    .padding()
            }
            
            Tab("Nauka", systemImage: "book.pages", value: .study) {
                NavigationStack {
                    StudyView()
                }
            }
            
            Tab("Statystyki", systemImage: "chart.bar", value: .statistics) {
                StatisticsView()
            }
            
            Tab("Ustawienia", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
        }
    }
}

#Preview {
//    let manager = CoreDataManager.preview
//    let service = CategoryService(manager: manager)
//    let vm = StudyViewModel(categoryService: service)
    
    ContentView()
    
//    do {
//        let previewer = try Previewer()
//        
//        return ContentView()
//            .modelContainer(previewer.container)
//    } catch {
//        return Text(error.localizedDescription)
//    }
}
