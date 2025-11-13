//
//  MockShoppingListRepository.swift
//  QuickarrTests
//
//  Mock implementation for testing
//

import Foundation
@testable import Quickarr

actor MockShoppingListRepository: ShoppingListRepository {
    private var lists: [UUID: ShoppingList] = [:]
    
    func fetchAll() async throws -> [ShoppingList] {
        Array(lists.values)
    }
    
    func fetch(id: UUID) async throws -> ShoppingList? {
        lists[id]
    }
    
    func save(_ list: ShoppingList) async throws {
        lists[list.id] = list
    }
    
    func delete(id: UUID) async throws {
        lists.removeValue(forKey: id)
    }
    
    // Helper for testing
    func reset() {
        lists.removeAll()
    }
}
