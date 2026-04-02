//
//  FailedFilesSectionView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 02/04/2026.
//

import SwiftUI

struct FailedFilesSectionView: View {
    let files: [GenerateWithAIViewModel.FailedImport]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        Section {
            ForEach(files) { failed in
                Label {
                    VStack(alignment: .leading) {
                        Text(failed.fileName)
                        Text(failed.error.localizedDescription)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } icon: {
                    Image(systemName: "exclamationmark.circle.fill")
                }
                .animation(.default, value: files)
            }
            .onDelete(perform: onDelete)
            .listItemTint(.red)
        }
    }
}
