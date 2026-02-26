//
//  TagEntity+CoreDataProperties.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/02/2026.
//
//

public import Foundation
public import CoreData


public typealias TagEntityCoreDataPropertiesSet = NSSet

extension TagEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntity> {
        return NSFetchRequest<TagEntity>(entityName: "TagEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var studySet: StudySetEntity?

}

extension TagEntity : Identifiable {

}
