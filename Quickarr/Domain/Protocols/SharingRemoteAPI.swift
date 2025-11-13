//
//  SharingRemoteAPI.swift
//  Quickarr
//
//  Domain protocol for future REST-based sharing
//

import Foundation

/// Error types for remote sharing API
public enum SharingRemoteAPIError: Error {
    case notImplemented
    case networkError(Error)
    case invalidResponse
    case unauthorized
}

/// Remote API protocol for REST-based sharing (future implementation)
public protocol SharingRemoteAPI: Sendable {
    /// Upload a shopping list to the remote server
    /// - Parameter list: The shopping list to upload
    /// - Returns: A remote ID for the uploaded list
    func uploadList(_ list: ShoppingList) async throws -> String
    
    /// Sync updates for a shopping session
    /// - Parameters:
    ///   - session: The shopping session to sync
    ///   - list: The associated shopping list
    func syncUpdates(session: ShoppingSession, list: ShoppingList) async throws
    
    /// Download a shared list by ID
    /// - Parameter remoteId: The remote list ID
    /// - Returns: The shopping list
    func downloadList(remoteId: String) async throws -> ShoppingList
}
