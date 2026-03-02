//
//  CoreDataManager.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData

class CoreDataManager {
    static let instance = CoreDataManager()
    
    private static var _previewInstance: CoreDataManager?
    
    static var preview: CoreDataManager {
        if let existing = _previewInstance {
            return existing
        }
        
        let manager = CoreDataManager(inMemory: true)
        let context = manager.context
        
        let superTag = TagEntity(context: context)
        superTag.name = "SuperTag"
        
        let category1 = CategoryEntity(context: context)
        category1.name = "Category1"
        category1.systemIcon = "laptopcomputer"
        for i in 1..<6 {
            let newSet = StudySetEntity(context: context)
            newSet.name = "Set \(i)"
            for j in 1..<5 {
                let newTag = TagEntity(context: context)
                newTag.name = "Tag \(i).\(j)"
                newSet.addToTags(newTag)
            }
            if i != 1 {
                newSet.addToTags(superTag)
            }
            category1.addToStudySets(newSet)
        }
        
        let category2 = CategoryEntity(context: context)
        category2.name = "Category2"
        category2.systemIcon = "pill.fill"
        for i in 1..<6 {
            let newSet = StudySetEntity(context: context)
            newSet.name = "Set \(i)"
            category2.addToStudySets(newSet)
        }
        
        manager.save()
        _previewInstance = manager
        return manager
    }
    
    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreDataContainer")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data failed: \(error)")
            }
        }
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
}
