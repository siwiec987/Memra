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
    @ObservationIgnored let studySetService: StudySetService
    
    private(set) var categories: [CategoryEntity] = []
    private(set) var tags: [TagEntity] = []
    
    var studySetName = ""
    var newTagName = ""
    var selectedCategory: CategoryEntity?
    var selectedStudySet: StudySetEntity?
    
    let isEditing: Bool
    var isSaveDisabled: Bool {
        studySetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        selectedCategory == nil
        
    }
    
    var initialTags: [TagEntity] = []
    var selectedTags: [TagEntity] = []
    
    var remainingTags: [TagEntity] {
        tags.filter { !selectedTags.contains($0) && !initialTags.contains($0) }
    }
    
    var sortedTags: [TagEntity] {
        selectedTags + initialTags + remainingTags
    }
    
    init(
        categoryService: CategoryService = CategoryService(manager: CoreDataManager.instance),
        tagService: TagService = TagService(manager: CoreDataManager.instance),
        studySetService: StudySetService = StudySetService(manager: CoreDataManager.instance),
        selectedCategory: CategoryEntity? = nil,
        selectedStudySet: StudySetEntity? = nil
    ) {
        self.categoryService = categoryService
        self.tagService = tagService
        self.studySetService = studySetService
        
        if let selectedStudySet {
            self.selectedStudySet = selectedStudySet
            self.studySetName = selectedStudySet.wrappedName
            self.initialTags = Array(selectedStudySet.tagsSet)
            self.isEditing = true
        } else {
            self.isEditing = false
        }    
        
        reload()
        
        if let selectedCategory {
            self.selectedCategory = selectedCategory
        } else {
            self.selectedCategory = categories.first
        }
    }
    
    func toggleTag(_ tag: TagEntity) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else if initialTags.contains(tag) {
            initialTags.removeAll { $0 == tag }
        } else {
            selectedTags.insert(tag, at: 0)
        }
    }
    
    private func reload() {
        categories = categoryService.fetchAll(sortedBy: .studySetCount, direction: .descending)
        tags = tagService.fetchAll(sortedBy: .studySetCount, direction: .descending)
    }
    
    func save() {
        if isEditing {
            guard let selectedStudySet else { return }
            studySetService.edit(selectedStudySet)
        } else {
            guard let selectedCategory else { return }
            studySetService.add(name: studySetName, category: selectedCategory, tags: selectedTags)
        }
    }
}
