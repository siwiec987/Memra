//
//  EditCategoryViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 21/02/2026.
//

import CoreData
import Foundation

@Observable
class EditCategoryViewModel: Identifiable {
    @ObservationIgnored private let editContext: NSManagedObjectContext
    @ObservationIgnored private let persistence: PersistenceController
    @ObservationIgnored private var initialSnapshot: CategorySnapshot?
    
    var categoryName = ""
    var selectedColor: CategoryEntity.AccentColor = .default
    var selectedIconName = "graduationcap"
    
    var selectedCategory: CategoryEntity
    let isEditing: Bool
    
    init(
        persistence: PersistenceController = PersistenceController.instance,
        editing categoryID: NSManagedObjectID
    ) throws {
        self.persistence = persistence
        self.editContext = persistence.newChildContext()
        self.isEditing = true

        guard let category = try? editContext.existingObject(with: categoryID) as? CategoryEntity else {
            throw EditCategoryError.categoryNotFound
        }

        self.selectedCategory = category
        categoryName = category.wrappedName
        selectedIconName = category.wrappedSystemIcon
        selectedColor = category.accentColor
        
        takeSnapshot()
    }

    init(
        persistence: PersistenceController = PersistenceController.instance
    ) {
        self.persistence = persistence
        self.editContext = persistence.newChildContext()
        self.isEditing = false
        self.selectedCategory = CategoryEntity(context: editContext)
    }
    
    var isSaveDisabled: Bool {
        categoryName.trimmed().isEmpty ||
        selectedIconName.trimmed().isEmpty
    }
    
    var availableColors: [CategoryEntity.AccentColor] {
        CategoryEntity.AccentColor.allCases
    }
    
    var hasUnsavedChanges: Bool {
        guard let snapshot = initialSnapshot else { return false }
        
        return categoryName.trimmed() != snapshot.name ||
                selectedColor != snapshot.color ||
                selectedIconName != snapshot.iconName
    }
    
    private func takeSnapshot() {
        initialSnapshot = CategorySnapshot(
            name: categoryName.trimmed(),
            color: selectedColor,
            iconName: selectedIconName.trimmed()
        )
    }
    
    func save() {
        let trimmedName = categoryName.trimmed()
        guard !trimmedName.isEmpty else { return }
        selectedCategory.name = trimmedName
        selectedCategory.accentColor = selectedColor
        selectedCategory.systemIcon = selectedIconName
        
        if isEditing {
            guard (try? editContext.save()) != nil else { return }
            persistence.save()
        }
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
    
    private struct CategorySnapshot {
        let name: String
        let color: CategoryEntity.AccentColor
        let iconName: String
    }
}
