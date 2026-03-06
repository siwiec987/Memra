//
//  FlashcardService.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import Foundation

class FlashcardService: DataService {
    typealias Entity = FlashcardEntity
    
    let manager: PersistenceController

    required init(manager: PersistenceController) {
        self.manager = manager
    }
    
    func fetchAll(sortedBy: SortOption? = nil, direction: SortDirection = .ascending) -> [FlashcardEntity] {
        let request = FlashcardEntity.fetchRequest()
        
        if let sortedBy {
            request.sortDescriptors = [sortedBy.descriptor(for: direction)]
        }
        
        return (try? manager.viewContext.fetch(request)) ?? []
    }
    
    func add(_ entity: FlashcardEntity) {
        
    }
    
    func delete(_ entity: FlashcardEntity) {
        
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nazwa"
        
        func directionLabel(for direction: SortDirection) -> String {
            direction == .ascending ? "Rosnąco" : "Malejąco"
        }
        
        func descriptor(for direction: SortDirection) -> NSSortDescriptor {
            let ascending = direction == .ascending
            return switch self {
            case .name:
                NSSortDescriptor(key: "name", ascending: ascending)
            }
        }
        
        var id: String { rawValue }
    }
}
