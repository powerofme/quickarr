//
//  MockShoppingSessionRepository.swift
//  QuickarrTests
//
//  Mock implementation for testing
//

import Foundation
@testable import Quickarr

actor MockShoppingSessionRepository: ShoppingSessionRepository {
    private var sessions: [UUID: ShoppingSession] = [:]
    
    func fetchAll() async throws -> [ShoppingSession] {
        Array(sessions.values)
    }
    
    func fetchActiveSessions() async throws -> [ShoppingSession] {
        sessions.values.filter { $0.isActive }
    }
    
    func fetch(id: UUID) async throws -> ShoppingSession? {
        sessions[id]
    }
    
    func fetchSessions(forListId listId: UUID) async throws -> [ShoppingSession] {
        sessions.values.filter { $0.listId == listId }
    }
    
    func save(_ session: ShoppingSession) async throws {
        sessions[session.id] = session
    }
    
    func delete(id: UUID) async throws {
        sessions.removeValue(forKey: id)
    }
    
    // Helper for testing
    func reset() {
        sessions.removeAll()
    }
}
