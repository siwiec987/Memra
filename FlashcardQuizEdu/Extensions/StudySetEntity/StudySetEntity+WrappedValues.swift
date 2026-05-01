//
//  StudySetEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension StudySetEntity {
    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue.trimmed() }
    }

    var tagsSet: Set<TagEntity> {
        (tags as? Set<TagEntity>) ?? []
    }
    
    var flashcardSet: Set<FlashcardEntity> {
        (flashcards as? Set<FlashcardEntity>) ?? []
    }
    
    var questionSet: Set<QuizQuestionEntity> {
        (questions as? Set<QuizQuestionEntity>) ?? []
    }
}
