//
//  ShoppingSession.swift
//  Quickarr
//
//  Domain entity for active shopping sessions
//

import Foundation

/// Represents an active shopping session for a list
public struct ShoppingSession: Identifiable, Codable, Sendable {
    public let id: UUID
    public let listId: UUID
    public let startedAt: Date
    public var endedAt: Date?
    public var itemSnapshots: [UUID: ItemStatus] // Maps item ID to status
    
    public init(
        id: UUID = UUID(),
        listId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        itemSnapshots: [UUID: ItemStatus] = [:]
    ) {
        self.id = id
        self.listId = listId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.itemSnapshots = itemSnapshots
    }
    
    /// Whether the session is still active
    public var isActive: Bool {
        endedAt == nil
    }
    
    /// Duration of the session
    public var duration: TimeInterval {
        let end = endedAt ?? Date()
        return end.timeIntervalSince(startedAt)
    }
    
    /// Update item status in the session
    public mutating func updateItemStatus(itemId: UUID, status: ItemStatus) {
        itemSnapshots[itemId] = status
    }
    
    /// End the session
    public mutating func end() {
        endedAt = Date()
    }
}
