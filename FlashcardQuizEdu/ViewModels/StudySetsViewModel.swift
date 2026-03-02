//
//  StudySetsViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import Foundation

@Observable
class StudySetsViewModel {
    @ObservationIgnored let studySetService: StudySetService
    @ObservationIgnored let category: CategoryEntity
    
    var studySets: [StudySetEntity] = []
    var tags: [TagEntity] = []
    
    private(set) var selectedTags: [TagEntity] = []
    
    var sortOption: StudySetService.SortOption = .name {
        didSet {
            reload()
            UserDefaults.standard.set(sortOption.rawValue, forKey: "StudySetsSortOption")
        }
    }
    var sortDirection: SortDirection = .descending {
        didSet {
            reload()
            UserDefaults.standard.set(sortDirection.rawValue, forKey: "StudySetsSortDirection")
        }
    }
    
    var title: String {
        category.wrappedName
    }
    
    init(
        category: CategoryEntity,
        studySetService: StudySetService = StudySetService(manager: CoreDataManager.instance)
    ) {
        self.category = category
        self.studySetService = studySetService
        
        if let savedOption = UserDefaults.standard.string(forKey: "StudySetsSortOption"), let option = StudySetService.SortOption(rawValue: savedOption) {
            self.sortOption = option
        }
        
        let savedDirection = UserDefaults.standard.integer(forKey: "StudySetsSortDirection")
        if let direction = SortDirection(rawValue: savedDirection) {
            self.sortDirection = direction
        }
        
        reload()
        let tagSet = studySets.reduce(into: Set<TagEntity>()) { result, set in
            result.formUnion(set.tagsSet)
        }
        self.tags = tagSet.sorted {
            ($0.studySetCount != $1.studySetCount) ? ($0.studySetCount > $1.studySetCount) : ($0.wrappedName > $1.wrappedName)
        }
    }
    
    var allTags: [TagEntity] {
        selectedTags + tags.filter { !selectedTags.contains($0) }
    }
    
    private func reload() {
        studySets = studySetService.fetchFiltered(
            tags: selectedTags,
            category: category,
            sortedBy: sortOption,
            direction: sortDirection
        )
    }
    
    func toggleTag(_ tag: TagEntity) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
        
        reload()
    }
    
    func clearTags() {
        selectedTags.removeAll()
        reload()
    }
    
    func directionLabel(for direction: SortDirection) -> String {
        sortOption.directionLabel(for: direction)
    }
}
