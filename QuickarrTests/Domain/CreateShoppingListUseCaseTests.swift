//
//  CreateShoppingListUseCaseTests.swift
//  QuickarrTests
//
//  Tests for CreateShoppingListUseCase
//

import XCTest
@testable import Quickarr

final class CreateShoppingListUseCaseTests: XCTestCase {
    var repository: MockShoppingListRepository!
    var useCase: CreateShoppingListUseCase!
    
    override func setUp() async throws {
        repository = MockShoppingListRepository()
        useCase = CreateShoppingListUseCase(repository: repository)
    }
    
    override func tearDown() async throws {
        await repository.reset()
        repository = nil
        useCase = nil
    }
    
    func testCreateList() async throws {
        let list = try await useCase.execute(name: "Groceries")
        
        XCTAssertEqual(list.name, "Groceries")
        XCTAssertEqual(list.totalItems, 0)
        
        let savedList = try await repository.fetch(id: list.id)
        XCTAssertNotNil(savedList)
        XCTAssertEqual(savedList?.name, "Groceries")
    }
}
