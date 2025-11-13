//
//  ShoppingChangeEvent.swift
//  Quickarr
//
//  Domain entity for tracking changes during shopping
//

import Foundation

/// Represents a change event during shopping
public struct ShoppingChangeEvent: Identifiable, Codable, Sendable {
    public let id: UUID
    public let sessionId: UUID
    public let itemId: UUID
    public let itemName: String
    public let previousStatus: ItemStatus
    public let newStatus: ItemStatus
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        itemId: UUID,
        itemName: String,
        previousStatus: ItemStatus,
        newStatus: ItemStatus,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.itemId = itemId
        self.itemName = itemName
        self.previousStatus = previousStatus
        self.newStatus = newStatus
        self.timestamp = timestamp
    }
    
    /// Human-readable description of the change
    public var description: String {
        switch (previousStatus, newStatus) {
        case (.pending, .picked):
            return "\(itemName) picked"
        case (.pending, .unavailable):
            return "\(itemName) unavailable"
        case (.pending, .substituted(let sub)):
            return "\(itemName) substituted with \(sub.name)"
        case (_, .picked):
            return "\(itemName) marked as picked"
        case (_, .unavailable):
            return "\(itemName) marked as unavailable"
        case (_, .substituted(let sub)):
            return "\(itemName) substituted with \(sub.name)"
        default:
            return "\(itemName) status changed"
        }
    }
}
