//
//  FlashcardEntity+createdAt.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 13/03/2026.
//

import Foundation

extension FlashcardEntity {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.setPrimitiveValue(Date.now, forKey: "createdAt")
    }
}
