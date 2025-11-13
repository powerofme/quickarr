//
//  ItemCategory.swift
//  Quickarr
//
//  Domain entity representing shopping item categories
//

import Foundation

/// Categories for organizing shopping items
public enum ItemCategory: String, Codable, CaseIterable, Sendable {
    case produce
    case dairy
    case meat
    case bakery
    case frozen
    case pantry
    case beverages
    case snacks
    case household
    case healthBeauty
    case other
    
    /// Display name for the category
    public var displayName: String {
        switch self {
        case .produce: return "Produce"
        case .dairy: return "Dairy"
        case .meat: return "Meat & Seafood"
        case .bakery: return "Bakery"
        case .frozen: return "Frozen"
        case .pantry: return "Pantry"
        case .beverages: return "Beverages"
        case .snacks: return "Snacks"
        case .household: return "Household"
        case .healthBeauty: return "Health & Beauty"
        case .other: return "Other"
        }
    }
    
    /// SF Symbol icon name for the category
    public var iconName: String {
        switch self {
        case .produce: return "leaf.fill"
        case .dairy: return "drop.fill"
        case .meat: return "fish.fill"
        case .bakery: return "birthday.cake.fill"
        case .frozen: return "snowflake"
        case .pantry: return "cabinet.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .snacks: return "popcorn.fill"
        case .household: return "house.fill"
        case .healthBeauty: return "heart.fill"
        case .other: return "tray.fill"
        }
    }
}
