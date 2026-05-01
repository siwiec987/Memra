//
//  PersistenceController.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 16/02/2026.
//

import CoreData

@MainActor
final class PersistenceController {
    static let instance = PersistenceController()
    
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreDataContainer")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data failed: \(error)")
            }
        }
        
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    func newChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return context
    }
    
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
}

extension PersistenceController {
    static var preview: PersistenceController {
        let manager = PersistenceController(inMemory: true)
        let context = manager.viewContext
        
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

            if i == 1 {
                let flashcard1 = FlashcardEntity(context: context)
                flashcard1.question = "What is SwiftUI?"
                flashcard1.answer = "A declarative framework for building user interfaces across Apple platforms."
                newSet.addToFlashcards(flashcard1)

                let flashcard2 = FlashcardEntity(context: context)
                flashcard2.question = "What does Core Data manage?"
                flashcard2.answer = "It manages the model layer objects and persistence in an Apple app."
                newSet.addToFlashcards(flashcard2)

                let quizQuestion1 = QuizQuestionEntity(context: context)
                quizQuestion1.text = "Which framework is used here to build UI?"

                let quizAnswer1A = QuizAnswerEntity(context: context)
                quizAnswer1A.text = "SwiftUI"
                quizAnswer1A.isCorrect = true
                quizQuestion1.addToAnswers(quizAnswer1A)

                let quizAnswer1B = QuizAnswerEntity(context: context)
                quizAnswer1B.text = "UIKit for Android"
                quizAnswer1B.isCorrect = false
                quizQuestion1.addToAnswers(quizAnswer1B)

                let quizQuestion2 = QuizQuestionEntity(context: context)
                quizQuestion2.text = "What is Core Data mainly used for?"

                let quizAnswer2A = QuizAnswerEntity(context: context)
                quizAnswer2A.text = "Persisting app data"
                quizAnswer2A.isCorrect = true
                quizQuestion2.addToAnswers(quizAnswer2A)

                let quizAnswer2B = QuizAnswerEntity(context: context)
                quizAnswer2B.text = "Rendering 3D graphics"
                quizAnswer2B.isCorrect = false
                quizQuestion2.addToAnswers(quizAnswer2B)

                newSet.addToQuestions(quizQuestion1)
                newSet.addToQuestions(quizQuestion2)
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
        return manager
    }
}
