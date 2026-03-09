//
//  View+SwipeEditDeleteActions.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 09/03/2026.
//

import SwiftUI

extension View {
    func swipeEditDeleteActions(onDelete: @escaping () -> Void, onEdit: @escaping () -> Void) -> some View {
        modifier(SwipeEditDeleteActions(onDelete: onDelete, onEdit: onEdit))
    }
}

struct SwipeEditDeleteActions: ViewModifier {
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    func body(content: Content) -> some View {
        content
            .swipeActions(allowsFullSwipe: true) {
                Button("Usuń", systemImage: "trash.fill", role: .destructive, action: onDelete)
                .tint(.red)
            }
            .swipeActions {
                Button("Edytuj", systemImage: "pencil", action: onEdit)
                .tint(.orange)
            }
    }
}
