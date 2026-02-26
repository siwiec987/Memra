//
//  FlashcardEntity+CoreDataProperties.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 17/02/2026.
//
//

public import Foundation
public import CoreData


public typealias FlashcardEntityCoreDataPropertiesSet = NSSet

extension FlashcardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlashcardEntity> {
        return NSFetchRequest<FlashcardEntity>(entityName: "FlashcardEntity")
    }

    @NSManaged public var answer: String?
    @NSManaged public var question: String?
    @NSManaged public var studySet: StudySetEntity?

}

extension FlashcardEntity : Identifiable {

}
