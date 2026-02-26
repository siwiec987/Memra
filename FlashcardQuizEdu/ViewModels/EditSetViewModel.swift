//
//  EditSetViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/02/2026.
//

import Foundation

@Observable
class EditSetViewModel {
    @ObservationIgnored let categoryService: CategoryService
    @ObservationIgnored let tagService: TagService
    
    init(
        categoryService: CategoryService = CategoryService(manager: CoreDataManager.instance),
        tagService: TagService = TagService(manager: CoreDataManager.instance),
        selectedCategory: CategoryEntity? = nil
    ) {
        self.categoryService = categoryService
        self.tagService = tagService
        
        self.categories = categoryService.fetchAll(sortedBy: .studySetCount, direction: .descending)
        self.tags = tagService.fetchAll(sortedBy: .studySetCount, direction: .descending)
        
        if let selectedCategory {
            self.selectedCategory = selectedCategory
        } else {
            self.selectedCategory = categories.first
        }
    }
    
    var name = ""
    var selectedCategory: CategoryEntity?
    
    var categories: [CategoryEntity]
    var tags: [TagEntity]
}
