//
//  ShoppingListRepository.swift
//  Quickarr
//
//  Domain protocol for shopping list persistence
//

import Foundation

/// Repository protocol for managing shopping lists
public protocol ShoppingListRepository: Sendable {
    /// Fetch all shopping lists
    func fetchAll() async throws -> [ShoppingList]
    
    /// Fetch a specific shopping list by ID
    func fetch(id: UUID) async throws -> ShoppingList?
    
    /// Save a shopping list (create or update)
    func save(_ list: ShoppingList) async throws
    
    /// Delete a shopping list
    func delete(id: UUID) async throws
}
