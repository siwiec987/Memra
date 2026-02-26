//
//  SortingPickerView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 24/02/2026.
//

import SwiftUI

struct SortingPicker<Option: RawRepresentable & CaseIterable & Identifiable & Hashable>: View where Option.RawValue == String, Option.AllCases == [Option] {
    @Binding var optionSelection: Option
    @Binding var directionSelection: SortDirection
    let directionLabel: (SortDirection) -> String
    
    var body: some View {
        Menu("Sort", systemImage: "arrow.up.arrow.down") {
            Picker("Sort option", selection: $optionSelection) {
                ForEach(Option.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }

            Divider()

            Picker("Sort direction", selection: $directionSelection) {
                ForEach(SortDirection.allCases) { direction in
                    Text(directionLabel(direction)).tag(direction)
                }
            }
        }
    }
}
