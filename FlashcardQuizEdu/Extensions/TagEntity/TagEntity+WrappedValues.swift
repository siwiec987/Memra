//
//  TagEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension TagEntity {
    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue.trimmed() }
    }
}
