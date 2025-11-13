//
//  GetActiveShoppingSessionsUseCase.swift
//  Quickarr
//
//  Domain use case for retrieving active shopping sessions
//

import Foundation

/// Use case for getting active shopping sessions
public struct GetActiveShoppingSessionsUseCase: Sendable {
    private let sessionRepository: ShoppingSessionRepository
    
    public init(sessionRepository: ShoppingSessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    /// Execute the use case
    /// - Returns: Array of active shopping sessions
    public func execute() async throws -> [ShoppingSession] {
        try await sessionRepository.fetchActiveSessions()
    }
}
