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
    @ObservationIgnored let persistence: PersistenceController
    @ObservationIgnored let category: CategoryEntity
    @ObservationIgnored private var frc: NSFetchedResultsController<StudySetEntity>
    
    private(set) var studySets: [StudySetEntity] = []
    private(set) var tags: [TagEntity] = []
    
    private(set) var selectedTags: [TagEntity] = []
    
    var sortOption: SortOption = .name {
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
        persistence: PersistenceController = PersistenceController.instance
    ) {
        self.category = category
        self.persistence = persistence
        
        let savedOption = UserDefaults.standard.string(forKey: "StudySetsSortOption")
        let initialSortOption = SortOption(rawValue: savedOption ?? "") ?? .name
        self.sortOption = initialSortOption

        let savedDirection = UserDefaults.standard.integer(forKey: "StudySetsSortDirection")
        let initialSortDirection = SortDirection(rawValue: savedDirection) ?? .descending
        self.sortDirection = initialSortDirection

        let request = StudySetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [initialSortOption.descriptor(for: initialSortDirection)]
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistence.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
    
    func delete(_ studySet: StudySetEntity) {
        persistence.viewContext.delete(studySet)
        persistence.save()
        persistence.viewContext.refreshAllObjects()
    }
    
    private func reload() {
        var predicates: [NSPredicate] = []
        
        if !selectedTags.isEmpty {
            predicates.append(NSPredicate(format: "ANY tags IN %@", selectedTags))
        }
        
        predicates.append(NSPredicate(format: "category == %@", category))
        
        frc.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        frc.fetchRequest.sortDescriptors = [sortOption.descriptor(for: sortDirection)]
        try? frc.performFetch()
        syncFromFRC()
    }
    
    private func syncFromFRC() {
        studySets = frc.fetchedObjects ?? []
        updateTags()
    }
    
    private func updateTags() {
        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY studySets.category == %@", category)
        request.sortDescriptors = [
            NSSortDescriptor(key: "studySetCount", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        tags = (try? persistence.viewContext.fetch(request)) ?? []
        selectedTags.removeAll { !tags.contains($0) }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nazwa"
        case createdAt = "Data utworzenia"
        case flashcardCount = "Liczba fiszek"
        case tagCount = "Liczba tagów"
        
        func directionLabel(for direction: SortDirection) -> String {
            let ascending = direction == .ascending
            return switch self {
            case .name, .flashcardCount, .tagCount:
                ascending ? "Rosnąco" : "Malejąco"
            case .createdAt:
                ascending ? "Od najstarszych" : "Od najnowszych"
            }
        }
        
        func descriptor(for direction: SortDirection) -> NSSortDescriptor {
            let ascending = direction == .ascending
            return switch self {
            case .name:
                NSSortDescriptor(key: "name", ascending: ascending)
            case .createdAt:
                NSSortDescriptor(key: "createdAt", ascending: ascending)
            case .flashcardCount:
                NSSortDescriptor(key: "flashcardCount", ascending: ascending)
            case .tagCount:
                NSSortDescriptor(key: "tagCount", ascending: ascending)
            }
        }
        
        var id: String { rawValue }
    }
}

extension StudySetsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [StudySetEntity] else { return }
        studySets = objects
        updateTags()
    }
}
