//
//  StudySetService.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import Foundation

class StudySetService: DataService {
    typealias Entity = StudySetEntity
    
    let manager: CoreDataManager

    required init(manager: CoreDataManager) {
        self.manager = manager
    }
    
    func fetchAll(sortedBy: SortOption? = nil, direction: SortDirection = .ascending) -> [StudySetEntity] {
        let request = StudySetEntity.fetchRequest()
        
        if let sortedBy {
            request.sortDescriptors = [sortedBy.descriptor(for: direction)]
        }
        
        return (try? manager.context.fetch(request)) ?? []
    }
    
    func add(_ entity: StudySetEntity) {
        
    }
    
    func delete(_ entity: StudySetEntity) {
        
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nazwa"
        case createdAt = "Data utworzenia"
        case flashcardCount = "Ilość elementów"
        
        func directionLabel(for direction: SortDirection) -> String {
            let ascending = direction == .ascending
            return switch self {
            case .name, .flashcardCount:
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
            }
        }
        
        var id: String { rawValue }
    }
}
