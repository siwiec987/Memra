//
//  StudySetService.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData
import Foundation

class StudySetService: DataService {
    typealias Entity = StudySetEntity
    
    let manager: PersistenceController

    required init(manager: PersistenceController) {
        self.manager = manager
    }
    
    func makeFetchRequest(
        tags: [TagEntity] = [],
        category: CategoryEntity? = nil,
        sortedBy: SortOption? = nil,
        direction: SortDirection = .ascending
    ) -> NSFetchRequest<StudySetEntity> {
        let request = StudySetEntity.fetchRequest()
        var predicates: [NSPredicate] = []
        
        if !tags.isEmpty {
            predicates.append(NSPredicate(format: "ANY tags IN %@", tags))
        }
        
        if let category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        if let sortedBy {
            request.sortDescriptors = [sortedBy.descriptor(for: direction)]
        }
        
        return request
    }
    
    func fetchAll(sortedBy sortOption: SortOption? = nil, direction: SortDirection = .ascending) -> [StudySetEntity] {
        let request = makeFetchRequest(sortedBy: sortOption, direction: direction)
        return (try? manager.viewContext.fetch(request)) ?? []
    }
    
    func fetchFiltered(
        tags: [TagEntity] = [],
        category: CategoryEntity? = nil,
        sortedBy: SortOption? = nil,
        direction: SortDirection = .ascending
    ) -> [StudySetEntity] {
        let request = makeFetchRequest(tags: tags, category: category, sortedBy: sortedBy, direction: direction)
        return (try? manager.viewContext.fetch(request)) ?? []
    }
    
    func add(name: String, category: CategoryEntity, tags: [TagEntity]) {
        let studySet = StudySetEntity(context: manager.viewContext)
        studySet.name = name
        studySet.category = category
        studySet.addToTags(NSSet(array: tags))
        manager.save()
    }
    
    func edit(_ studySet: StudySetEntity, name: String? = nil, category: CategoryEntity? = nil, tags: [TagEntity]? = nil) {
        if let name { studySet.name = name }
        if let category { studySet.category = category }
        if let tags { studySet.tags = NSSet(array: tags) }
        manager.save()
    }
    
    func delete(_ entity: StudySetEntity) {
        manager.viewContext.delete(entity)
        manager.save()
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
