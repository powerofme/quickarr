//
//  ShoppingSessionRepository.swift
//  Quickarr
//
//  Domain protocol for shopping session persistence
//

import Foundation

/// Repository protocol for managing shopping sessions
public protocol ShoppingSessionRepository: Sendable {
    /// Fetch all shopping sessions
    func fetchAll() async throws -> [ShoppingSession]
    
    /// Fetch active sessions
    func fetchActiveSessions() async throws -> [ShoppingSession]
    
    /// Fetch a specific session by ID
    func fetch(id: UUID) async throws -> ShoppingSession?
    
    /// Fetch sessions for a specific list
    func fetchSessions(forListId listId: UUID) async throws -> [ShoppingSession]
    
    /// Save a shopping session (create or update)
    func save(_ session: ShoppingSession) async throws
    
    /// Delete a session
    func delete(id: UUID) async throws
}
