//
//  SwiftDataShoppingListRepository.swift
//  Quickarr
//
//  SwiftData-based implementation of ShoppingListRepository
//

import Foundation
import SwiftData

/// SwiftData model for ShoppingList persistence
@Model
final class ShoppingListModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var itemsData: Data?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID, name: String, itemsData: Data?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.itemsData = itemsData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// SwiftData repository implementation
public actor SwiftDataShoppingListRepository: ShoppingListRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
    
    public func fetchAll() async throws -> [ShoppingList] {
        let descriptor = FetchDescriptor<ShoppingListModel>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.compactMap { try decode($0) }
    }
    
    public func fetch(id: UUID) async throws -> ShoppingList? {
        let descriptor = FetchDescriptor<ShoppingListModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            return nil
        }
        return try decode(model)
    }
    
    public func save(_ list: ShoppingList) async throws {
        let encoder = JSONEncoder()
        let itemsData = try encoder.encode(list.items)
        
        // Check if exists
        let descriptor = FetchDescriptor<ShoppingListModel>(
            predicate: #Predicate { $0.id == list.id }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            // Update
            existing.name = list.name
            existing.itemsData = itemsData
            existing.updatedAt = list.updatedAt
        } else {
            // Insert
            let model = ShoppingListModel(
                id: list.id,
                name: list.name,
                itemsData: itemsData,
                createdAt: list.createdAt,
                updatedAt: list.updatedAt
            )
            modelContext.insert(model)
        }
        
        try modelContext.save()
    }
    
    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<ShoppingListModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
    
    // MARK: - Private
    
    private func decode(_ model: ShoppingListModel) throws -> ShoppingList {
        let decoder = JSONDecoder()
        let items: [ShoppingItem]
        
        if let itemsData = model.itemsData {
            items = try decoder.decode([ShoppingItem].self, from: itemsData)
        } else {
            items = []
        }
        
        return ShoppingList(
            id: model.id,
            name: model.name,
            items: items,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
