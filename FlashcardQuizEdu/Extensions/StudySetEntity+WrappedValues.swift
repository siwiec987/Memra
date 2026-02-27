//
//  StudySetEntity+WrappedValues.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 26/02/2026.
//

extension StudySetEntity {
    var wrappedName: String {
        name ?? ""
    }

    var tagsSet: Set<TagEntity> {
        (tags as? Set<TagEntity>) ?? []
    }
}
