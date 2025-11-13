//
//  ItemStatus.swift
//  Quickarr
//
//  Domain entity representing item status during shopping
//

import Foundation

/// Status of an item during a shopping session
public enum ItemStatus: Codable, Sendable, Equatable {
    case pending
    case picked
    case unavailable
    case substituted(SubstituteItem)
    
    /// Display name for the status
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .picked: return "Picked"
        case .unavailable: return "Unavailable"
        case .substituted: return "Substituted"
        }
    }
    
    /// SF Symbol icon for the status
    public var iconName: String {
        switch self {
        case .pending: return "circle"
        case .picked: return "checkmark.circle.fill"
        case .unavailable: return "xmark.circle.fill"
        case .substituted: return "arrow.triangle.2.circlepath"
        }
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case type
        case substituteItem
    }
    
    private enum StatusType: String, Codable {
        case pending
        case picked
        case unavailable
        case substituted
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StatusType.self, forKey: .type)
        
        switch type {
        case .pending:
            self = .pending
        case .picked:
            self = .picked
        case .unavailable:
            self = .unavailable
        case .substituted:
            let item = try container.decode(SubstituteItem.self, forKey: .substituteItem)
            self = .substituted(item)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .pending:
            try container.encode(StatusType.pending, forKey: .type)
        case .picked:
            try container.encode(StatusType.picked, forKey: .type)
        case .unavailable:
            try container.encode(StatusType.unavailable, forKey: .type)
        case .substituted(let item):
            try container.encode(StatusType.substituted, forKey: .type)
            try container.encode(item, forKey: .substituteItem)
        }
    }
}
