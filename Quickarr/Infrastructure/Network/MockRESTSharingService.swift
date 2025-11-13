//
//  MockRESTSharingService.swift
//  Quickarr
//
//  Mock REST sharing service for future implementation
//

import Foundation

/// Mock REST API implementation (stub for future)
public actor MockRESTSharingService: SharingRemoteAPI {
    
    // Local storage for mock data
    private var uploadedLists: [String: ShoppingList] = [:]
    private var syncedSessions: [String: ShoppingSession] = [:]
    
    public init() {}
    
    public func uploadList(_ list: ShoppingList) async throws -> String {
        // Generate a mock remote ID
        let remoteId = "list_\(UUID().uuidString)"
        uploadedLists[remoteId] = list
        
        print("📤 [Mock REST] Uploaded list '\(list.name)' with ID: \(remoteId)")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        return remoteId
    }
    
    public func syncUpdates(session: ShoppingSession, list: ShoppingList) async throws {
        let sessionId = "session_\(session.id.uuidString)"
        syncedSessions[sessionId] = session
        
        print("🔄 [Mock REST] Synced updates for session: \(sessionId)")
        print("   List: \(list.name)")
        print("   Items tracked: \(session.itemSnapshots.count)")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
    }
    
    public func downloadList(remoteId: String) async throws -> ShoppingList {
        guard let list = uploadedLists[remoteId] else {
            throw SharingRemoteAPIError.invalidResponse
        }
        
        print("📥 [Mock REST] Downloaded list: \(list.name)")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        return list
    }
    
    // MARK: - Testing helpers
    
    public func getUploadedLists() -> [String: ShoppingList] {
        uploadedLists
    }
    
    public func getSyncedSessions() -> [String: ShoppingSession] {
        syncedSessions
    }
    
    public func reset() {
        uploadedLists.removeAll()
        syncedSessions.removeAll()
    }
}

/// Composite sharing service that routes to appropriate channel
public actor CompositeSharingService: SharingService {
    private let iMessageService: iMessageSharingService
    private let restAPI: MockRESTSharingService
    
    public init(
        iMessageService: iMessageSharingService,
        restAPI: MockRESTSharingService
    ) {
        self.iMessageService = iMessageService
        self.restAPI = restAPI
    }
    
    public func share(list: ShoppingList, via channel: SharingChannel) async throws {
        switch channel {
        case .iMessage:
            try await iMessageService.share(list: list, via: channel)
        case .rest:
            _ = try await restAPI.uploadList(list)
        }
    }
    
    public func sendUpdate(for session: ShoppingSession, list: ShoppingList, via channel: SharingChannel) async throws {
        switch channel {
        case .iMessage:
            try await iMessageService.sendUpdate(for: session, list: list, via: channel)
        case .rest:
            try await restAPI.syncUpdates(session: session, list: list)
        }
    }
}
