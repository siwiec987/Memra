//
//  EditSetViewModel.swift
//  FlashcardQuizEdu
//
//  Created by Jakub Siwiec on 23/02/2026.
//

import CoreData
import Foundation

@Observable
class EditSetViewModel {
    @ObservationIgnored let editContext: NSManagedObjectContext
    @ObservationIgnored private let persistence: PersistenceController
    @ObservationIgnored private var initialSnapshot: StudySetSnapshot?
    
    private(set) var categories: [CategoryEntity] = []
    private(set) var tags: [TagEntity] = []
    
    var newTagName = ""
    
    var studySetName = ""
    var selectedCategory: CategoryEntity?
    var selectedTagIDs: Set<NSManagedObjectID> = []
    var createdTags: Set<TagEntity> = []
    var selectedStudySet: StudySetEntity
    
    let isEditing: Bool
    
    init(
        persistence: PersistenceController = PersistenceController.instance,
        studySetID: NSManagedObjectID? = nil,
        categoryID: NSManagedObjectID? = nil
    ) {
        self.persistence = persistence
        self.editContext = persistence.newChildContext()
        
        if let studySetID, let studySet = try? editContext.existingObject(with: studySetID) as? StudySetEntity {
            self.selectedStudySet = studySet
            self.isEditing = true
        } else {
            self.selectedStudySet = StudySetEntity(context: editContext)
            self.isEditing = false
        }
        
        fetchCategories()
        fetchTags()
        
        if self.selectedStudySet.category == nil {
            if let categoryID, let category = try? editContext.existingObject(with: categoryID) as? CategoryEntity {
                self.selectedStudySet.category = category
            } else {
                self.selectedStudySet.category = categories.first
            }
        }
        
        self.studySetName = selectedStudySet.wrappedName
        self.selectedCategory = selectedStudySet.category
        self.selectedTagIDs = Set(selectedStudySet.tagsSet.map { $0.objectID })
        takeSnapshot()
    }
    
    var tagsSorted: [TagEntity] {
        tags.sorted { $0.wrappedName < $1.wrappedName }
    }
    
    var newTagNameTrimmed: String {
        newTagName.trimmed()
    }
    
    var isSaveDisabled: Bool {
        studySetName.trimmed().isEmpty ||
        selectedCategory == nil
    }
    
    var hasUnsavedChanges: Bool {
        guard let snapshot = initialSnapshot else { return false }
        
        return studySetName.trimmed() != snapshot.name ||
                selectedCategory?.objectID != snapshot.categoryID ||
                selectedTagIDs != snapshot.tagIDs ||
                !newTagNameTrimmed.isEmpty
    }
    
    private func takeSnapshot() {
        initialSnapshot = StudySetSnapshot(
            name: studySetName.trimmed(),
            categoryID: selectedCategory?.objectID,
            tagIDs: selectedTagIDs
        )
    }
    
    private func fetchCategories() {
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "studySetCount", ascending: false)]
        categories = (try? editContext.fetch(request)) ?? []
    }
    
    private func fetchTags() {
        let request = TagEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.tags = (try? editContext.fetch(request)) ?? []
    }
    
    func toggleTag(_ tag: TagEntity) {
        let tagID = tag.objectID
        if selectedTagIDs.contains(tagID) {
            selectedTagIDs.remove(tagID)
        } else {
            selectedTagIDs.insert(tagID)
        }
    }
    
    func save() {
        selectedStudySet.name = studySetName.trimmed()
        selectedStudySet.category = selectedCategory
        selectedStudySet.tags = NSSet(array: tags.filter { selectedTagIDs.contains($0.objectID) })
        
        createdTags.forEach { tag in
            if !selectedTagIDs.contains(tag.objectID) {
                editContext.delete(tag)
            }
        }
        
        guard selectedStudySet.category != nil else { return print("Kategoria pusta") }
        guard !selectedStudySet.wrappedName.isEmpty else { return print("nazwa pusta")}
        guard ((try? editContext.save()) != nil) else { return }
        persistence.save()
        print("Dochodzimy tu w ogole?")
    }
    
    func newCategory(_ category: CategoryEntity) {
        let newCategory = CategoryEntity(context: editContext)
        newCategory.name = category.wrappedName
        newCategory.accentColor = category.accentColor
        newCategory.systemIcon = category.wrappedSystemIcon
        
        selectedCategory = newCategory
        categories.insert(newCategory, at: 0)
    }
    
    func addTag() {
        guard !newTagNameTrimmed.isEmpty else { return }
        guard !tags.contains(where: { $0.wrappedName.caseInsensitiveCompare(newTagNameTrimmed) == .orderedSame }) else { return }
        
        let newTag = TagEntity(context: editContext)
        newTag.name = newTagNameTrimmed
        tags.append(newTag)
        createdTags.insert(newTag)
        selectedTagIDs.insert(newTag.objectID)
        newTagName = ""
    }
    
    private struct StudySetSnapshot {
        let name: String
        let categoryID: NSManagedObjectID?
        let tagIDs: Set<NSManagedObjectID>
    }
}
