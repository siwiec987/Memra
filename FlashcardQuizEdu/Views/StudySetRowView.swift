//
//  StudySetRowView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 13/03/2026.
//

import SwiftUI

struct StudySetRowView: View {
    @ObservedObject var studySet: StudySetEntity
    
    var body: some View {
        Text(studySet.wrappedName)
    }
}

#Preview {
    let persistence = PersistenceController.preview
    let request = StudySetEntity.fetchRequest()
    request.fetchLimit = 1
    let studySet = (try? persistence.viewContext.fetch(request))?.first ?? StudySetEntity(context: persistence.viewContext)
    
    return StudySetRowView(studySet: studySet)
}
