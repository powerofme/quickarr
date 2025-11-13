//
//  ShoppingItem.swift
//  Quickarr
//
//  Domain entity for shopping list items
//

import Foundation

/// Represents an item in a shopping list
public struct ShoppingItem: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let category: ItemCategory
    public var status: ItemStatus
    public let notes: String?
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: ItemCategory,
        status: ItemStatus = .pending,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Create a copy with updated status
    public func withStatus(_ newStatus: ItemStatus) -> ShoppingItem {
        ShoppingItem(
            id: id,
            name: name,
            category: category,
            status: newStatus,
            notes: notes,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}
