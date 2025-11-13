//
//  CreateShoppingListUseCase.swift
//  Quickarr
//
//  Domain use case for creating shopping lists
//

import Foundation

/// Use case for creating a new shopping list
public struct CreateShoppingListUseCase: Sendable {
    private let repository: ShoppingListRepository
    
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }
    
    /// Execute the use case
    /// - Parameter name: Name for the new list
    /// - Returns: The created shopping list
    public func execute(name: String) async throws -> ShoppingList {
        let list = ShoppingList(name: name)
        try await repository.save(list)
        return list
    }
}
