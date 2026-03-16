//
//  StudySetEntity+createdAt.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 13/03/2026.
//

import Foundation

extension StudySetEntity {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.setPrimitiveValue(Date.now, forKey: "createdAt")
    }
    
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        guard let context = managedObjectContext else { return }
        
        let tagsToDelete = tagsSet.filter { $0.studySetCount <= 1 }
        tagsToDelete.forEach { context.delete($0) }
    }
}
