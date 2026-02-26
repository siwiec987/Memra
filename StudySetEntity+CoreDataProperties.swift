//
//  StudySetEntity+CoreDataProperties.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/02/2026.
//
//

public import Foundation
public import CoreData


public typealias StudySetEntityCoreDataPropertiesSet = NSSet

extension StudySetEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StudySetEntity> {
        return NSFetchRequest<StudySetEntity>(entityName: "StudySetEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: CategoryEntity?
    @NSManaged public var flashcards: NSSet?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for flashcards
extension StudySetEntity {

    @objc(addFlashcardsObject:)
    @NSManaged public func addToFlashcards(_ value: FlashcardEntity)

    @objc(removeFlashcardsObject:)
    @NSManaged public func removeFromFlashcards(_ value: FlashcardEntity)

    @objc(addFlashcards:)
    @NSManaged public func addToFlashcards(_ values: NSSet)

    @objc(removeFlashcards:)
    @NSManaged public func removeFromFlashcards(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension StudySetEntity {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: TagEntity)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: TagEntity)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension StudySetEntity : Identifiable {

}
