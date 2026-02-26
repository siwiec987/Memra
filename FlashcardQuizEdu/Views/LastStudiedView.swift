//
//  LastStudiedView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 22/01/2026.
//

import SwiftUI

struct LastStudiedView: View {
    var body: some View {
        VStack {
            Text("Kontynuuj")
            Text("Jakiś zestaw")
                .font(.title)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.secondary)
        .clipShape(.rect(cornerRadius: 15))
    }
}

#Preview {
    LastStudiedView()
}
