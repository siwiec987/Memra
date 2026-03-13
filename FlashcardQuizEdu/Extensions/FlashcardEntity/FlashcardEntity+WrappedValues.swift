//
//  FlashcardEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension FlashcardEntity {
    var wrappedQuestion: String {
        question ?? ""
    }

    var wrappedAnswer: String {
        answer ?? ""
    }
}
