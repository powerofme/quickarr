//
//  SuggestCategoryForItemUseCase.swift
//  Quickarr
//
//  Domain use case for suggesting item categories
//

import Foundation

/// Use case for suggesting a category for an item
public struct SuggestCategoryForItemUseCase: Sendable {
    private let categorySuggestionService: CategorySuggestionService
    
    public init(categorySuggestionService: CategorySuggestionService) {
        self.categorySuggestionService = categorySuggestionService
    }
    
    /// Execute the use case
    /// - Parameter itemName: Name of the item to categorize
    /// - Returns: The suggested category
    public func execute(itemName: String) async throws -> ItemCategory {
        guard !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw UseCaseError.invalidInput
        }
        
        return try await categorySuggestionService.suggestCategory(for: itemName)
    }
}
