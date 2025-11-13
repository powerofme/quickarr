//
//  StartShoppingSessionUseCase.swift
//  Quickarr
//
//  Domain use case for starting a shopping session
//

import Foundation

/// Use case for starting a new shopping session
public struct StartShoppingSessionUseCase: Sendable {
    private let sessionRepository: ShoppingSessionRepository
    private let listRepository: ShoppingListRepository
    
    public init(
        sessionRepository: ShoppingSessionRepository,
        listRepository: ShoppingListRepository
    ) {
        self.sessionRepository = sessionRepository
        self.listRepository = listRepository
    }
    
    /// Execute the use case
    /// - Parameter listId: ID of the list to start shopping for
    /// - Returns: The created shopping session
    public func execute(forListId listId: UUID) async throws -> ShoppingSession {
        guard let list = try await listRepository.fetch(id: listId) else {
            throw UseCaseError.listNotFound
        }
        
        // Initialize session with all items in pending state
        var itemSnapshots: [UUID: ItemStatus] = [:]
        for item in list.items {
            itemSnapshots[item.id] = item.status
        }
        
        let session = ShoppingSession(
            listId: listId,
            itemSnapshots: itemSnapshots
        )
        
        try await sessionRepository.save(session)
        return session
    }
}
