//
//  SharingService.swift
//  Quickarr
//
//  Domain protocol for sharing shopping lists
//

import Foundation

/// Channel through which to share content
public enum SharingChannel: Sendable {
    case iMessage
    case rest
}

/// Service protocol for sharing shopping lists and updates
public protocol SharingService: Sendable {
    /// Share a shopping list via the specified channel
    /// - Parameters:
    ///   - list: The shopping list to share
    ///   - channel: The sharing channel to use
    func share(list: ShoppingList, via channel: SharingChannel) async throws
    
    /// Send an update for a shopping session via the specified channel
    /// - Parameters:
    ///   - session: The shopping session to update about
    ///   - list: The associated shopping list
    ///   - channel: The sharing channel to use
    func sendUpdate(for session: ShoppingSession, list: ShoppingList, via channel: SharingChannel) async throws
}
