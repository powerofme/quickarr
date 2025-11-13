//
//  SubstituteItem.swift
//  Quickarr
//
//  Domain entity for substitute items
//

import Foundation

/// Represents a substitute for an unavailable item
public struct SubstituteItem: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let category: ItemCategory
    public let notes: String?
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: ItemCategory,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.notes = notes
    }
}
