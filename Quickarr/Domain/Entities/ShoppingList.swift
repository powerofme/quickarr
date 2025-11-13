//
//  ShoppingList.swift
//  Quickarr
//
//  Domain entity for shopping lists
//

import Foundation

/// Represents a shopping list with items
public struct ShoppingList: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var items: [ShoppingItem]
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        items: [ShoppingItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Total number of items
    public var totalItems: Int {
        items.count
    }
    
    /// Number of picked items
    public var pickedCount: Int {
        items.filter { item in
            if case .picked = item.status { return true }
            return false
        }.count
    }
    
    /// Number of unavailable items
    public var unavailableCount: Int {
        items.filter { item in
            if case .unavailable = item.status { return true }
            return false
        }.count
    }
    
    /// Number of substituted items
    public var substitutedCount: Int {
        items.filter { item in
            if case .substituted = item.status { return true }
            return false
        }.count
    }
    
    /// Items grouped by category
    public var itemsByCategory: [ItemCategory: [ShoppingItem]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    /// Add an item to the list
    public mutating func addItem(_ item: ShoppingItem) {
        items.append(item)
        updatedAt = Date()
    }
    
    /// Update an item in the list
    public mutating func updateItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            updatedAt = Date()
        }
    }
    
    /// Remove an item from the list
    public mutating func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        updatedAt = Date()
    }
}
