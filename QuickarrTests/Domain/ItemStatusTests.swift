//
//  ItemStatusTests.swift
//  QuickarrTests
//
//  Tests for ItemStatus entity and Equatable conformance
//

import XCTest
@testable import Quickarr

final class ItemStatusTests: XCTestCase {
    
    func testEquatableSimpleCases() {
        // Test simple enum cases
        XCTAssertEqual(ItemStatus.pending, ItemStatus.pending)
        XCTAssertEqual(ItemStatus.picked, ItemStatus.picked)
        XCTAssertEqual(ItemStatus.unavailable, ItemStatus.unavailable)
        
        // Test inequality
        XCTAssertNotEqual(ItemStatus.pending, ItemStatus.picked)
        XCTAssertNotEqual(ItemStatus.picked, ItemStatus.unavailable)
    }
    
    func testEquatableSubstitutedCase() {
        // Create identical substitute items
        let substitute1 = SubstituteItem(id: UUID(), name: "Yogurt", category: .dairy, notes: "Low fat")
        let substitute2 = SubstituteItem(id: substitute1.id, name: "Yogurt", category: .dairy, notes: "Low fat")
        
        let status1 = ItemStatus.substituted(substitute1)
        let status2 = ItemStatus.substituted(substitute2)
        
        // Test equality for substituted status with same values
        XCTAssertEqual(status1, status2)
        
        // Create different substitute item
        let substitute3 = SubstituteItem(name: "Milk", category: .dairy)
        let status3 = ItemStatus.substituted(substitute3)
        
        // Test inequality for different substitutes
        XCTAssertNotEqual(status1, status3)
        
        // Test inequality between simple and substituted cases
        XCTAssertNotEqual(ItemStatus.pending, status1)
    }
    
    func testSubstituteItemEquatable() {
        // Test SubstituteItem Equatable conformance directly
        let item1 = SubstituteItem(id: UUID(), name: "Yogurt", category: .dairy, notes: "Low fat")
        let item2 = SubstituteItem(id: item1.id, name: "Yogurt", category: .dairy, notes: "Low fat")
        let item3 = SubstituteItem(id: UUID(), name: "Milk", category: .dairy, notes: nil)
        
        XCTAssertEqual(item1, item2)
        XCTAssertNotEqual(item1, item3)
    }
}
