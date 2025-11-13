//
//  MockCategorySuggestionService.swift
//  QuickarrTests
//
//  Mock implementation for testing
//

import Foundation
@testable import Quickarr

actor MockCategorySuggestionService: CategorySuggestionService {
    private var mockSuggestions: [String: ItemCategory] = [:]
    var defaultCategory: ItemCategory = .other
    
    func suggestCategory(for itemName: String) async throws -> ItemCategory {
        mockSuggestions[itemName.lowercased()] ?? defaultCategory
    }
    
    func suggestCategories(for itemNames: [String]) async throws -> [String: ItemCategory] {
        var results: [String: ItemCategory] = [:]
        for name in itemNames {
            results[name] = mockSuggestions[name.lowercased()] ?? defaultCategory
        }
        return results
    }
    
    // Helper for testing
    func setMockSuggestion(itemName: String, category: ItemCategory) {
        mockSuggestions[itemName.lowercased()] = category
    }
    
    func reset() {
        mockSuggestions.removeAll()
        defaultCategory = .other
    }
}
