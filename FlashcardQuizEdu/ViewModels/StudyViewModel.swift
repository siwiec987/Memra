//
//  StudyViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData
import Foundation

@Observable
@MainActor
class StudyViewModel: NSObject {
    @ObservationIgnored let persistence: PersistenceController
    @ObservationIgnored private var frc: NSFetchedResultsController<CategoryEntity>
    
    private(set) var categories: [CategoryEntity] = []
    
    var sortOption: SortOption = .name {
        didSet {
            reload()
            UserDefaults.standard.set(sortOption.rawValue, forKey: "StudySortOption")
        }
    }
    var sortDirection: SortDirection = .descending {
        didSet {
            reload()
            UserDefaults.standard.set(sortDirection.rawValue, forKey: "StudySortDirection")
        }
    }
    
    init(persistence: PersistenceController = PersistenceController.instance) {
        self.persistence = persistence
        
        let savedOption = UserDefaults.standard.string(forKey: "StudySortOption")
        let initialSortOption = SortOption(rawValue: savedOption ?? "") ?? .name
        self.sortOption = initialSortOption

        let savedDirection = UserDefaults.standard.integer(forKey: "StudySortDirection")
        let initialSortDirection = SortDirection(rawValue: savedDirection) ?? .descending
        self.sortDirection = initialSortDirection
        
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [initialSortOption.descriptor(for: initialSortDirection)]
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistence.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        frc.delegate = self
        try? frc.performFetch()
        self.categories = frc.fetchedObjects ?? []
    }
    
    func directionLabel(for direction: SortDirection) -> String {
        sortOption.directionLabel(for: direction)
    }
    
    func delete(_ category: CategoryEntity) {
        persistence.viewContext.delete(category)
        persistence.save()
    }
    
    private func reload() {
        frc.fetchRequest.sortDescriptors = [sortOption.descriptor(for: sortDirection)]
        try? frc.performFetch()
        categories = frc.fetchedObjects ?? []
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nazwa"
        case createdAt = "Data utworzenia"
        case studySetCount = "Ilość zestawów"
        
        func directionLabel(for direction: SortDirection) -> String {
            let ascending = direction == .ascending
            return switch self {
            case .name, .studySetCount:
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
            case .studySetCount:
                NSSortDescriptor(key: "studySetCount", ascending: ascending)
            }
        }
        
        var id: String { rawValue }
    }
}

extension StudyViewModel: @MainActor NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [CategoryEntity] else { return }
        categories = objects
    }
}
