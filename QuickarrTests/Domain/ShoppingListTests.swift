//
//  ShoppingListTests.swift
//  QuickarrTests
//
//  Tests for ShoppingList entity
//

import XCTest
@testable import Quickarr

final class ShoppingListTests: XCTestCase {
    
    func testCreateEmptyList() {
        let list = ShoppingList(name: "Groceries")
        
        XCTAssertEqual(list.name, "Groceries")
        XCTAssertEqual(list.totalItems, 0)
        XCTAssertEqual(list.pickedCount, 0)
        XCTAssertEqual(list.unavailableCount, 0)
        XCTAssertEqual(list.substitutedCount, 0)
    }
    
    func testAddItem() {
        var list = ShoppingList(name: "Groceries")
        let item = ShoppingItem(name: "Milk", category: .dairy)
        
        list.addItem(item)
        
        XCTAssertEqual(list.totalItems, 1)
        XCTAssertEqual(list.items.first?.name, "Milk")
        XCTAssertEqual(list.items.first?.category, .dairy)
    }
    
    func testUpdateItem() {
        var list = ShoppingList(name: "Groceries")
        let item = ShoppingItem(name: "Milk", category: .dairy)
        list.addItem(item)
        
        let updatedItem = item.withStatus(.picked)
        list.updateItem(updatedItem)
        
        XCTAssertEqual(list.pickedCount, 1)
        if case .picked = list.items.first?.status {
            // Success
        } else {
            XCTFail("Item status should be picked")
        }
    }
    
    func testRemoveItem() {
        var list = ShoppingList(name: "Groceries")
        let item = ShoppingItem(name: "Milk", category: .dairy)
        list.addItem(item)
        
        list.removeItem(id: item.id)
        
        XCTAssertEqual(list.totalItems, 0)
    }
    
    func testItemsByCategory() {
        var list = ShoppingList(name: "Groceries")
        list.addItem(ShoppingItem(name: "Milk", category: .dairy))
        list.addItem(ShoppingItem(name: "Cheese", category: .dairy))
        list.addItem(ShoppingItem(name: "Apple", category: .produce))
        
        let grouped = list.itemsByCategory
        
        XCTAssertEqual(grouped[.dairy]?.count, 2)
        XCTAssertEqual(grouped[.produce]?.count, 1)
    }
    
    func testStatusCounts() {
        var list = ShoppingList(name: "Groceries")
        let item1 = ShoppingItem(name: "Milk", category: .dairy, status: .picked)
        let item2 = ShoppingItem(name: "Cheese", category: .dairy, status: .unavailable)
        let substitute = SubstituteItem(name: "Yogurt", category: .dairy)
        let item3 = ShoppingItem(name: "Bread", category: .bakery, status: .substituted(substitute))
        let item4 = ShoppingItem(name: "Apple", category: .produce)
        
        list.addItem(item1)
        list.addItem(item2)
        list.addItem(item3)
        list.addItem(item4)
        
        XCTAssertEqual(list.totalItems, 4)
        XCTAssertEqual(list.pickedCount, 1)
        XCTAssertEqual(list.unavailableCount, 1)
        XCTAssertEqual(list.substitutedCount, 1)
    }
}
