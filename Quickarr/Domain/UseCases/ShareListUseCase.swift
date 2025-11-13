//
//  ShareListUseCase.swift
//  Quickarr
//
//  Domain use case for sharing shopping lists
//

import Foundation

/// Use case for sharing a shopping list
public struct ShareListUseCase: Sendable {
    private let listRepository: ShoppingListRepository
    private let sharingService: SharingService
    
    public init(
        listRepository: ShoppingListRepository,
        sharingService: SharingService
    ) {
        self.listRepository = listRepository
        self.sharingService = sharingService
    }
    
    /// Execute the use case
    /// - Parameters:
    ///   - listId: ID of the list to share
    ///   - channel: The sharing channel to use
    public func execute(listId: UUID, via channel: SharingChannel) async throws {
        guard let list = try await listRepository.fetch(id: listId) else {
            throw UseCaseError.listNotFound
        }
        
        try await sharingService.share(list: list, via: channel)
    }
}
