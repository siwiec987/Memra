//
//  DataService.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import Foundation

protocol DataService {
    associatedtype Entity
    associatedtype SortOption: RawRepresentable, CaseIterable, Identifiable where SortOption.RawValue == String
    init(manager: CoreDataManager)
    func fetchAll(sortedBy: SortOption?, direction: SortDirection) -> [Entity]
    func add(_ entity: Entity)
    func delete(_ entity: Entity)
}
