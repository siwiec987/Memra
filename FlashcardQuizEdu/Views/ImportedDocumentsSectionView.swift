//
//  ImportedDocumentsSectionView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 02/04/2026.
//

import SwiftUI

struct ImportedDocumentsSectionView: View {
    let documents: [ImportedFile]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        Section {
            ForEach(documents) { file in
                Label {
                    VStack(alignment: .leading) {
                        Text(file.fileName)
                        Text(file.fileSizeFormatted)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "document.fill")
                }
            }
            .onDelete(perform: withAnimation { onDelete })
        }
    }
}
