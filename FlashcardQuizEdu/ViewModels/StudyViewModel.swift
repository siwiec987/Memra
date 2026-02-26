//
//  CategoriesGridViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import Foundation

@Observable
class StudyViewModel {
    @ObservationIgnored let categoryService: CategoryService
    
    var categories: [CategoryEntity] = []
    
    init(categoryService: CategoryService = CategoryService(manager: CoreDataManager.instance)) {
        self.categoryService = categoryService
        
        self.categories = categoryService.fetchAll()
    }
}
