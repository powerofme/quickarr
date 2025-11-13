//
//  SendUpdateUseCase.swift
//  Quickarr
//
//  Domain use case for sending shopping session updates
//

import Foundation

/// Use case for sending updates about a shopping session
public struct SendUpdateUseCase: Sendable {
    private let sessionRepository: ShoppingSessionRepository
    private let listRepository: ShoppingListRepository
    private let sharingService: SharingService
    
    public init(
        sessionRepository: ShoppingSessionRepository,
        listRepository: ShoppingListRepository,
        sharingService: SharingService
    ) {
        self.sessionRepository = sessionRepository
        self.listRepository = listRepository
        self.sharingService = sharingService
    }
    
    /// Execute the use case
    /// - Parameters:
    ///   - sessionId: ID of the session to send update for
    ///   - channel: The sharing channel to use
    public func execute(sessionId: UUID, via channel: SharingChannel) async throws {
        guard let session = try await sessionRepository.fetch(id: sessionId) else {
            throw UseCaseError.sessionNotFound
        }
        
        guard let list = try await listRepository.fetch(id: session.listId) else {
            throw UseCaseError.listNotFound
        }
        
        try await sharingService.sendUpdate(for: session, list: list, via: channel)
    }
}
