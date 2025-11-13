//
//  UpdateItemStatusUseCase.swift
//  Quickarr
//
//  Domain use case for updating item status
//

import Foundation

/// Use case for updating item status in a shopping list
public struct UpdateItemStatusUseCase: Sendable {
    private let listRepository: ShoppingListRepository
    private let sessionRepository: ShoppingSessionRepository
    
    public init(
        listRepository: ShoppingListRepository,
        sessionRepository: ShoppingSessionRepository
    ) {
        self.listRepository = listRepository
        self.sessionRepository = sessionRepository
    }
    
    /// Execute the use case
    /// - Parameters:
    ///   - itemId: ID of the item to update
    ///   - newStatus: The new status
    ///   - listId: ID of the list containing the item
    ///   - sessionId: Optional session ID if updating during shopping
    public func execute(
        itemId: UUID,
        newStatus: ItemStatus,
        inListId listId: UUID,
        sessionId: UUID? = nil
    ) async throws {
        guard var list = try await listRepository.fetch(id: listId) else {
            throw UseCaseError.listNotFound
        }
        
        guard let itemIndex = list.items.firstIndex(where: { $0.id == itemId }) else {
            throw UseCaseError.itemNotFound
        }
        
        let updatedItem = list.items[itemIndex].withStatus(newStatus)
        list.updateItem(updatedItem)
        try await listRepository.save(list)
        
        // If in a session, update the session snapshot
        if let sessionId = sessionId,
           var session = try await sessionRepository.fetch(id: sessionId) {
            session.updateItemStatus(itemId: itemId, status: newStatus)
            try await sessionRepository.save(session)
        }
    }
}
