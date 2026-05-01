//
//  FlashcardEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension FlashcardEntity {
    var wrappedQuestion: String {
        get { question ?? "" }
        set { question = newValue.trimmed() }
    }

    var wrappedAnswer: String {
        get { answer ?? "" }
        set { answer = newValue.trimmed() }
    }
}
