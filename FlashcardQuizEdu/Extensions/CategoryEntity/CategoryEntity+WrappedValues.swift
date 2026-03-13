//
//  CategoryEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension CategoryEntity {
    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var wrappedSystemIcon: String {
        systemIcon ?? ""
    }
}
