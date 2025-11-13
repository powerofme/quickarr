//
//  AddItemToListUseCase.swift
//  Quickarr
//
//  Domain use case for adding items to shopping lists
//

import Foundation

/// Use case for adding an item to a shopping list
public struct AddItemToListUseCase: Sendable {
    private let repository: ShoppingListRepository
    
    public init(repository: ShoppingListRepository) {
        self.repository = repository
    }
    
    /// Execute the use case
    /// - Parameters:
    ///   - item: The item to add
    ///   - listId: ID of the list to add to
    public func execute(item: ShoppingItem, toListId listId: UUID) async throws {
        guard var list = try await repository.fetch(id: listId) else {
            throw UseCaseError.listNotFound
        }
        
        list.addItem(item)
        try await repository.save(list)
    }
}

/// Common use case errors
public enum UseCaseError: Error {
    case listNotFound
    case sessionNotFound
    case itemNotFound
    case invalidInput
}
