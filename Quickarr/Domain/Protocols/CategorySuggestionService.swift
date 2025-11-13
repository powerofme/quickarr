//
//  CategorySuggestionService.swift
//  Quickarr
//
//  Domain protocol for item category suggestion
//

import Foundation

/// Service protocol for suggesting categories for items
public protocol CategorySuggestionService: Sendable {
    /// Suggest a category for an item name
    /// - Parameter itemName: The name of the item
    /// - Returns: The suggested category, or .other if no suggestion available
    func suggestCategory(for itemName: String) async throws -> ItemCategory
    
    /// Batch suggest categories for multiple items
    /// - Parameter itemNames: Array of item names
    /// - Returns: Dictionary mapping item names to suggested categories
    func suggestCategories(for itemNames: [String]) async throws -> [String: ItemCategory]
}
