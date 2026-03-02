//
//  EditCategoryViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 21/02/2026.
//

import Foundation

@Observable
class EditCategoryViewModel {
    @ObservationIgnored private let categoryService: CategoryService
    
    var categoryName = ""
    var selectedColor: CategoryEntity.AccentColor = .default
    var selectedIconName = "graduationcap"
    
    let selectedCategory: CategoryEntity?
    
    init(
        categoryService: CategoryService = CategoryService(manager: CoreDataManager.instance),
        category: CategoryEntity? = nil
    ) {
        self.categoryService = categoryService
        
        if let category {
            self.categoryName = category.wrappedName
            self.selectedColor = category.accentColor
            self.selectedIconName = category.wrappedSystemIcon
            self.selectedCategory = category
        } else {
            self.selectedCategory = nil
        }
    }
    
    var isEditing: Bool {
        selectedCategory != nil
    }
    
    var isSaveDisabled: Bool {
        categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        selectedIconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var availableColors: [CategoryEntity.AccentColor] {
        CategoryEntity.AccentColor.allCases
    }
    
    func save() -> CategoryEntity? {
        if let selectedCategory {
            categoryService.edit(selectedCategory, name: categoryName, accentColor: selectedColor, systemIcon: selectedIconName)
        } else {
            return categoryService.add(name: categoryName, accentColor: selectedColor, systemIcon: selectedIconName)
        }
        
        return nil
    }
    
    let icons: [String] = [
        // Narzędzia / Organizacja / Inne
        "graduationcap",
        "paperclip",
        "bookmark",
        "folder",
        "highlighter",
        "doc.text",
        "calendar",
        "clock",
        "bell",
        "dice",
        
        // Nauki ścisłe (Math/Science)
        "function",
        "sum",
        "x.squareroot",
        "number",
        "ruler",
        "square.grid.3x3",
        "atom",
        "flask",
        "testtube.2",
        "camera.macro",
        "bolt",
        
        // Informatyka / Technologia
        "laptopcomputer",
        "desktopcomputer",
        "cpu",
        "keyboard",
        "display",
        "server.rack",
        "terminal",
        "gearshape",
        "gear",
        
        // Języki / Literatura
        "text.book.closed",
        "book",
        "books.vertical",
        "character.book.closed",
        "character",
        "quote.bubble",
        "quote.opening",
        "pencil",
        
        // Historia / Geografia
        "globe.europe.africa",
        "globe.americas",
        "globe.asia.australia",
        "map",
        "mappin.and.ellipse",
        "building.columns",
        "scroll",
        
        // Sztuka / Muzyka
        "paintbrush.pointed",
        "paintpalette",
        "theatermasks",
        "music.note",
        "music.quarternote.3",
        "camera",
        "video",
        
        // Biologia / Natura
        "leaf",
        "tree",
        "tortoise",
        "bird",
        "fish",
        "ladybug",
        "allergens",
        "microbe",
        
        // Zdrowie / Medycyna / Sport
        "stethoscope",
        "cross.case",
        "pills",
        "heart",
        "heart.text.square",
        "figure.run",
        "dumbbell",
        "trophy",
        
        // Biznes / Finanse / Ekonomia
        "chart.bar",
        "chart.line.uptrend.xyaxis",
        "creditcard",
        "banknote",
        "briefcase",
        
        // Języki obce / Komunikacja
        "globe",
        "bubble.left.and.bubble.right",
        "mic",
        "waveform",
        "translate",
    ]
}
