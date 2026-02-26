//
//  CategoriesService.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData
import Foundation

class CategoryService: DataService {
    typealias Entity = CategoryEntity
    
    let manager: CoreDataManager

    required init(manager: CoreDataManager) {
        self.manager = manager
    }
    
    func fetchAll(sortedBy sortOption: SortOption? = nil, direction: SortDirection = .ascending) -> [CategoryEntity] {
        let request = CategoryEntity.fetchRequest()
        
        if let sortOption {
            request.sortDescriptors = [sortOption.descriptor(for: direction)]
        }
        
        return (try? manager.context.fetch(request)) ?? []
    }
    
    func add(_ entity: CategoryEntity) {
        
    }
    
    func delete(_ entity: CategoryEntity) {
        
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Nazwa"
        case createdAt = "Data utworzenia"
        case studySetCount = "Ilość elementów"
        
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

//extension CategoryEntity {
//    override public func awakeFromInsert() {
//        super.awakeFromInsert()
//        self.createdAt = .now
//    }
//}
