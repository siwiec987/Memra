//
//  TagButton.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 25/02/2026.
//

import SwiftUI

struct TagButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var button: some View {
        Button(name, action: action)
    }
    
    var body: some View {
        if isSelected {
            button
                .buttonStyle(.borderedProminent)
        } else {
            button
                .buttonStyle(.bordered)
        }
    }
}
