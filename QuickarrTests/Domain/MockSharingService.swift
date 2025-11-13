//
//  MockSharingService.swift
//  QuickarrTests
//
//  Mock implementation for testing
//

import Foundation
@testable import Quickarr

actor MockSharingService: SharingService {
    private(set) var sharedLists: [(ShoppingList, SharingChannel)] = []
    private(set) var sentUpdates: [(ShoppingSession, ShoppingList, SharingChannel)] = []
    
    func share(list: ShoppingList, via channel: SharingChannel) async throws {
        sharedLists.append((list, channel))
    }
    
    func sendUpdate(for session: ShoppingSession, list: ShoppingList, via channel: SharingChannel) async throws {
        sentUpdates.append((session, list, channel))
    }
    
    // Helper for testing
    func reset() {
        sharedLists.removeAll()
        sentUpdates.removeAll()
    }
}
