//
//  TagService.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData
import Foundation

class TagService: DataService {
    typealias Entity = TagEntity
    
    let manager: PersistenceController

    required init(manager: PersistenceController) {
        self.manager = manager
    }
    
    func fetchAll(sortedBy: SortOption? = nil, direction: SortDirection = .ascending) -> [TagEntity] {
        let request = TagEntity.fetchRequest()
        
        if let sortedBy {
            request.sortDescriptors = [sortedBy.descriptor(for: direction)]
        }
        
        return (try? manager.viewContext.fetch(request)) ?? []
    }
    
    func add(name: String, studySet: StudySetEntity) {
        let tag = TagEntity(context: manager.viewContext)
        tag.addToStudySets(studySet)
        manager.save()
    }
    
    func delete(_ entity: TagEntity) {
        
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nazwa"
        case createdAt = "Data utworzenia"
        case studySetCount = "Ilość wystąpień"
        
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
