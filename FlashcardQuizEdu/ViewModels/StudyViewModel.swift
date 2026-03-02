//
//  CategoriesGridViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData
import Foundation

@Observable
class StudyViewModel: NSObject {
    @ObservationIgnored let categoryService: CategoryService
    @ObservationIgnored private var frc: NSFetchedResultsController<CategoryEntity>
    
    var categories: [CategoryEntity] = []
    
    init(
        categoryService: CategoryService = CategoryService(manager: CoreDataManager.instance),
        context: NSManagedObjectContext = CoreDataManager.instance.context
    ) {
        self.categoryService = categoryService
        
        let request = categoryService.makeFetchRequest(sortedBy: .studySetCount, direction: .descending)
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        frc.delegate = self
        try? frc.performFetch()
        self.categories = frc.fetchedObjects ?? []
    }
}

extension StudyViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [CategoryEntity] else { return }
        categories = objects
    }
}
