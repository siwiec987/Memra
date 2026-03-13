//
//  CategoryEntity+AccentColor.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 21/02/2026.
//

import SwiftUI

extension CategoryEntity {
    var accentColor: AccentColor {
        get {
            let rawValue = self.accentColorRawValue  ?? AccentColor.default.rawValue
            return (AccentColor(rawValue: rawValue) ?? .default)
        }
        set {
            self.accentColorRawValue = newValue.rawValue
        }
    }
    
    enum AccentColor: String, CaseIterable, Identifiable, Equatable {
        static let `default` = AccentColor.blue
        
        case red
        case orange
        case yellow
        case green
        case mint
        case cyan
        case blue
        case indigo
        case purple
        case pink
        case brown
        case gray
        
        var value: Color {
            switch self {
            case .red: .red
            case .orange: .orange
            case .yellow: .yellow
            case .green: .green
            case .mint: .mint
            case .cyan: .cyan
            case .blue: .blue
            case .indigo: .indigo
            case .purple: .purple
            case .pink: .pink
            case .brown: .brown
            case .gray: .gray
            }
        }
        
        var id: String { rawValue }
    }
}
