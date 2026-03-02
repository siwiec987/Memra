//
//  EditSetViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/02/2026.
//

import CoreData
import Foundation

// TODO: Ogarnij te tagi, bo to jest jakieś nieporozumienie co się tu dzieje

@Observable
class EditSetViewModel: NSObject {
    @ObservationIgnored let categoryService: CategoryService
    @ObservationIgnored let tagService: TagService
    @ObservationIgnored let studySetService: StudySetService
    
    @ObservationIgnored private var frc: NSFetchedResultsController<CategoryEntity>
    
    private(set) var categories: [CategoryEntity] = []
    private(set) var tags: [TagEntity] = []
    
    var studySetName = ""
    var newTagName = ""
    var selectedCategory: CategoryEntity?
    let selectedStudySet: StudySetEntity?
    
    var isSaveDisabled: Bool {
        studySetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        selectedCategory == nil
    }
    
    var initialTags: [TagEntity] = []
    var selectedTags: [TagEntity] = []
    
    var isEditing: Bool {
        selectedStudySet != nil
    }
    
    var remainingTags: [TagEntity] {
        tags.filter { !selectedTags.contains($0) && !initialTags.contains($0) }
    }
    
    var sortedTags: [TagEntity] {
        selectedTags + initialTags + remainingTags
    }

    private var finalTags: [TagEntity] {
        var seen: Set<NSManagedObjectID> = []
        return (selectedTags + initialTags).filter { tag in
            seen.insert(tag.objectID).inserted
        }
    }
    
    init(
        categoryService: CategoryService = CategoryService(manager: CoreDataManager.instance),
        tagService: TagService = TagService(manager: CoreDataManager.instance),
        studySetService: StudySetService = StudySetService(manager: CoreDataManager.instance),
        context: NSManagedObjectContext = CoreDataManager.instance.context,
        selectedCategory: CategoryEntity? = nil,
        selectedStudySet: StudySetEntity? = nil
    ) {
        self.categoryService = categoryService
        self.tagService = tagService
        self.studySetService = studySetService
        
        if let selectedStudySet {
            self.studySetName = selectedStudySet.wrappedName
            self.initialTags = Array(selectedStudySet.tagsSet)
            self.selectedCategory = selectedStudySet.category
            self.selectedStudySet = selectedStudySet
        } else {
            self.selectedStudySet = nil
        }
        
        let request = categoryService.makeFetchRequest(sortedBy: .studySetCount, direction: .descending)
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        frc.delegate = self
        try? frc.performFetch()
        categories = frc.fetchedObjects ?? []
        
        tags = tagService.fetchAll(sortedBy: .studySetCount, direction: .descending)
        
        if let selectedCategory {
            self.selectedCategory = selectedCategory
        } else {
            self.selectedCategory = categories.first
        }
    }
    
    func toggleTag(_ tag: TagEntity) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else if initialTags.contains(tag) {
            initialTags.removeAll { $0 == tag }
        } else {
            selectedTags.insert(tag, at: 0)
        }
    }
    
    func save() {
        guard let selectedCategory else { return }
        let trimmedName = studySetName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let selectedStudySet {
            studySetService.edit(selectedStudySet, name: trimmedName, category: selectedCategory, tags: finalTags)
        } else {
            studySetService.add(name: trimmedName, category: selectedCategory, tags: finalTags)
        }
    }
}

extension EditSetViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [CategoryEntity] else { return }
        categories = objects
        
        if let selectedCategory, categories.contains(selectedCategory) {
            return
        }
        
        selectedCategory = categories.first
    }
}
