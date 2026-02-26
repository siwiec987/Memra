//
//  EditCategoryView.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 21/02/2026.
//

import SwiftUI

struct EditCategoryView: View {
    @State private var vm = EditCategoryViewModel()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemName: vm.selectedIconName)
                        .resizable()
                        .symbolVariant(.fill)
                        .scaledToFit()
                        .padding(10)
                        .frame(width: 100, height: 100)
                        .padding()
                        .background(vm.selectedColor.value.gradient)
                        .clipShape(.circle)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Divider()

                    TextField("Tytuł", text: $vm.title)
                        .font(.title)
                        .bold()
                        .foregroundStyle(vm.selectedColor.value)
                }
            }
            
            Section {
                LazyVGrid(columns: columns) {
                    ForEach(vm.availableColors) { color in
                        Button {
                            vm.selectedColor = color
                        } label: {
                            Circle()
                                .fill(color.value)
                                .padding(5)
                                .overlay {
                                    Circle()
                                        .stroke(
                                            color.value.opacity(0.5),
                                            lineWidth: vm.selectedColor == color ? 4 : 0
                                        )
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Section {
                LazyVGrid(columns: columns) {
                    ForEach(vm.icons, id: \.self) { iconName in
                        Button {
                            vm.selectedIconName = iconName
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.secondary.opacity(0.2))
                                
                                Image(systemName: iconName)
                                    .symbolVariant(.fill)
                            }
                            .padding(5)
                            .overlay {
                                Circle()
                                    .stroke(
                                        .secondary.opacity(0.5),
                                        lineWidth: vm.selectedIconName == iconName ? 4 : 0
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Nowa kategoria")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    
                }
            }
        }
    }
}

#Preview {
    EditCategoryView()
}
