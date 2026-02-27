//
//  CategoryEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension CategoryEntity {
    var wrappedName: String {
        name ?? ""
    }

    var wrappedSystemIcon: String {
        systemIcon ?? ""
    }
}
