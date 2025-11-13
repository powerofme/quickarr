//
//  SwiftDataShoppingSessionRepository.swift
//  Quickarr
//
//  SwiftData-based implementation of ShoppingSessionRepository
//

import Foundation
import SwiftData

/// SwiftData model for ShoppingSession persistence
@Model
final class ShoppingSessionModel {
    @Attribute(.unique) var id: UUID
    var listId: UUID
    var startedAt: Date
    var endedAt: Date?
    var itemSnapshotsData: Data?
    
    init(id: UUID, listId: UUID, startedAt: Date, endedAt: Date?, itemSnapshotsData: Data?) {
        self.id = id
        self.listId = listId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.itemSnapshotsData = itemSnapshotsData
    }
}

/// SwiftData repository implementation
public actor SwiftDataShoppingSessionRepository: ShoppingSessionRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
    
    public func fetchAll() async throws -> [ShoppingSession] {
        let descriptor = FetchDescriptor<ShoppingSessionModel>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.compactMap { try decode($0) }
    }
    
    public func fetchActiveSessions() async throws -> [ShoppingSession] {
        let descriptor = FetchDescriptor<ShoppingSessionModel>(
            predicate: #Predicate { $0.endedAt == nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.compactMap { try decode($0) }
    }
    
    public func fetch(id: UUID) async throws -> ShoppingSession? {
        let descriptor = FetchDescriptor<ShoppingSessionModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            return nil
        }
        return try decode(model)
    }
    
    public func fetchSessions(forListId listId: UUID) async throws -> [ShoppingSession] {
        let descriptor = FetchDescriptor<ShoppingSessionModel>(
            predicate: #Predicate { $0.listId == listId },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.compactMap { try decode($0) }
    }
    
    public func save(_ session: ShoppingSession) async throws {
        let encoder = JSONEncoder()
        let snapshotsData = try encoder.encode(session.itemSnapshots)
        
        // Check if exists
        let descriptor = FetchDescriptor<ShoppingSessionModel>(
            predicate: #Predicate { $0.id == session.id }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            // Update
            existing.endedAt = session.endedAt
            existing.itemSnapshotsData = snapshotsData
        } else {
            // Insert
            let model = ShoppingSessionModel(
                id: session.id,
                listId: session.listId,
                startedAt: session.startedAt,
                endedAt: session.endedAt,
                itemSnapshotsData: snapshotsData
            )
            modelContext.insert(model)
        }
        
        try modelContext.save()
    }
    
    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<ShoppingSessionModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }
    
    // MARK: - Private
    
    private func decode(_ model: ShoppingSessionModel) throws -> ShoppingSession {
        let decoder = JSONDecoder()
        let itemSnapshots: [UUID: ItemStatus]
        
        if let snapshotsData = model.itemSnapshotsData {
            itemSnapshots = try decoder.decode([UUID: ItemStatus].self, from: snapshotsData)
        } else {
            itemSnapshots = [:]
        }
        
        return ShoppingSession(
            id: model.id,
            listId: model.listId,
            startedAt: model.startedAt,
            endedAt: model.endedAt,
            itemSnapshots: itemSnapshots
        )
    }
}
