//
//  CategoryEntity+CoreDataProperties.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/02/2026.
//
//

public import Foundation
public import CoreData


public typealias CategoryEntityCoreDataPropertiesSet = NSSet

extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var systemIcon: String?
    @NSManaged public var studySets: NSSet?

}

// MARK: Generated accessors for studySets
extension CategoryEntity {

    @objc(addStudySetsObject:)
    @NSManaged public func addToStudySets(_ value: StudySetEntity)

    @objc(removeStudySetsObject:)
    @NSManaged public func removeFromStudySets(_ value: StudySetEntity)

    @objc(addStudySets:)
    @NSManaged public func addToStudySets(_ values: NSSet)

    @objc(removeStudySets:)
    @NSManaged public func removeFromStudySets(_ values: NSSet)

}

extension CategoryEntity : Identifiable {

}
