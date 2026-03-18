//
//  RoundingSlider.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 18/03/2026.
//

import SwiftUI

struct RoundingSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let onEditingChanged: () -> Void
    
    private var valueRounded: Double {
        value.rounded()
    }
    
    init(value: Binding<Double>, range: ClosedRange<Double>, onEditingChanged: @escaping () -> Void = {}) {
        self._value = value
        self.range = range
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        HStack {
            Slider(value: $value, in: range) {
                Text("Ilość pytań")
            } onEditingChanged: { _ in
                value = valueRounded
                onEditingChanged()
            }

            Text(String(format: "%02d", Int(valueRounded)))
                .monospaced()
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(valueRounded == 0 ? .secondary : .primary)
        }
    }
}
