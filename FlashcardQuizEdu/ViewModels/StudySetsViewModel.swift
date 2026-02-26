//
//  StudySetsViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import Foundation

@Observable
class StudySetsViewModel {
//    @ObservationIgnored let title: String
    @ObservationIgnored let studySetService: StudySetService
    @ObservationIgnored let category: CategoryEntity
    
    var studySets: [StudySetEntity] = []
    var tags: [TagEntity] = []
    
    var sortOption: StudySetService.SortOption = .name {
        didSet {
            UserDefaults.standard.set(sortOption.rawValue, forKey: "StudySetsSortOption")
        }
    }
    var sortDirection: SortDirection = .descending {
        didSet {
            UserDefaults.standard.set(sortDirection.rawValue, forKey: "StudySetsSortDirection")
        }
    }
    
    var query = ""
    
//    private var _selectedTags: Set<TagEntity> = []
    
    var categoryName: String {
        return category.name ?? "Unknown"
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
        
        self.studySets = studySetService.fetchAll(sortedBy: sortOption, direction: sortDirection)
        let tagSet = Set(studySets.flatMap { ($0.tags as? Set<TagEntity>) ?? [] }) // tagSet ma być setem mordzia
        self.tags = tagSet.sorted {
            $0.studySetCount != $1.studySetCount ? $0.studySetCount > $1.studySetCount : $0.name ?? "" > $1.name ?? ""
        }
    }
    
    let availableTags: [TagEntity] = []
    let allTags: [TagEntity] = []
    var selectedTags: [TagEntity] = []
//    var selectedTags: [TagEntity] {
//        _selectedTags.sorted { $0.name ?? "" > $1.name ?? "" }
//    }
    
//    var availableTags: [TagEntity] {
//        var tagCounts: [TagEntity : Int] = [:]
//        
//        for set in studySets {
//            let tagSet = tagSetFor(set: set)
//            for tag in tagSet {
//                tagCounts[tag, default: 0] += 1
//            }
//        }
//
//        let filtered = tagCounts.filter { !_selectedTags.contains($0.key) }
//        let sorted = filtered.sorted { $0.key.name ?? "" > $1.key.name ?? "" }
//        
//        return sorted.sorted { $0.value > $1.value }.map { $0.key }
//    }
    
//    var allTags: [TagEntity] {
//        selectedTags + availableTags
//    }
    
//    var filteredStudySets: [StudySetEntity] {
//        let filtered = _selectedTags.isEmpty ? studySets : studySets.filter { set in
//            let tagSet = tagSetFor(set: set)
//            return !_selectedTags.isDisjoint(with: tagSet)
//        }
//        
//        return query.isEmpty ? filtered : filtered.filter { set in
//            set.name?.localizedStandardContains(query) ?? false
//        }
//    }
    
    func toggleTag(_ tag: TagEntity) {
//        if _selectedTags.contains(tag) {
//            _selectedTags.remove(tag)
//        } else {
//            _selectedTags.insert(tag)
//        }
    }
//    
    func clearTags() {
//        _selectedTags.removeAll()
    }
    
    func directionLabel(for direction: SortDirection) -> String {
        sortOption.directionLabel(for: direction)
    }
    
//    private func tagSetFor(set: StudySetEntity) -> Set<TagEntity> {
//        (set.tags as? Set<TagEntity>) ?? []
//    }
}
