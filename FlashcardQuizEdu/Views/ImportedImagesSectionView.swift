//
//  ImportedImagesSectionView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 02/04/2026.
//

import SwiftUI

struct ImportedImagesSectionView: View {
    let images: [ImportedImage]
    let onDelete: (UUID) -> Void
    
    var body: some View {
        if !images.isEmpty {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(images) { image in
                            Image(decorative: image.thumbnail, scale: 1)
                                .resizable()
                                .scaledToFill()
                                .clipShape(.rect(corners: .concentric(minimum: 15), isUniform: true))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation { onDelete(image.id) }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white, .black.opacity(0.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 150)
                .animation(.default, value: images)
            }
            .listRowInsets(.init())
        }
    }
}
