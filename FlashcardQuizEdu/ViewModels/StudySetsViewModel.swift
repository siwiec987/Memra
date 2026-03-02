//
//  StudySetsViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData
import Foundation

@Observable
class StudySetsViewModel: NSObject {
    @ObservationIgnored let studySetService: StudySetService
    @ObservationIgnored let category: CategoryEntity
    @ObservationIgnored private var frc: NSFetchedResultsController<StudySetEntity>
    
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
        studySetService: StudySetService = StudySetService(manager: CoreDataManager.instance),
        context: NSManagedObjectContext = CoreDataManager.instance.context
    ) {
        self.category = category
        self.studySetService = studySetService
        
        let savedOption = UserDefaults.standard.string(forKey: "StudySetsSortOption")
        let initialSortOption = StudySetService.SortOption(rawValue: savedOption ?? "") ?? .name
        self.sortOption = initialSortOption

        let savedDirection = UserDefaults.standard.integer(forKey: "StudySetsSortDirection")
        let initialSortDirection = SortDirection(rawValue: savedDirection) ?? .descending
        self.sortDirection = initialSortDirection

        let request = studySetService.makeFetchRequest(category: category, sortedBy: initialSortOption, direction: initialSortDirection)
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        frc.delegate = self
        reload()
    }
    
    var allTags: [TagEntity] {
        selectedTags + tags.filter { !selectedTags.contains($0) }
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
    
    private func reload() {
        let request = studySetService.makeFetchRequest(tags: selectedTags, category: category, sortedBy: sortOption, direction: sortDirection)
        frc.fetchRequest.predicate = request.predicate
        frc.fetchRequest.sortDescriptors = request.sortDescriptors
        try? frc.performFetch()
        syncFromFRC()
    }
    
    private func syncFromFRC() {
        studySets = frc.fetchedObjects ?? []
        updateTags()
    }
    
    private func updateTags() {
        let tagSet = studySets.reduce(into: Set<TagEntity>()) { result, set in
            result.formUnion(set.tagsSet)
        }
        tags = tagSet.sorted {
            ($0.studySetCount != $1.studySetCount) ?
            ($0.studySetCount > $1.studySetCount) :
            ($0.wrappedName > $1.wrappedName)
        }
        selectedTags.removeAll { !tags.contains($0) }
    }
}

extension StudySetsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [StudySetEntity] else { return }
        studySets = objects
        updateTags()
    }
}
