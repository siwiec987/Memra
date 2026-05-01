//
//  QuizQuestionEntity+wrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 28/04/2026.
//

extension QuizQuestionEntity {
    var wrappedText: String {
        get { text ?? "" }
        set { text = newValue.trimmed() }
    }
    
    var answerSet: Set<QuizAnswerEntity> {
        (answers as? Set<QuizAnswerEntity>) ?? []
    }
}
