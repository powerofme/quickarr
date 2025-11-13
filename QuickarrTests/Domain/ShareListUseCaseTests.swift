//
//  ShareListUseCaseTests.swift
//  QuickarrTests
//
//  Tests for ShareListUseCase
//

import XCTest
@testable import Quickarr

final class ShareListUseCaseTests: XCTestCase {
    var listRepository: MockShoppingListRepository!
    var sharingService: MockSharingService!
    var useCase: ShareListUseCase!
    
    override func setUp() async throws {
        listRepository = MockShoppingListRepository()
        sharingService = MockSharingService()
        useCase = ShareListUseCase(
            listRepository: listRepository,
            sharingService: sharingService
        )
    }
    
    override func tearDown() async throws {
        await listRepository.reset()
        await sharingService.reset()
        listRepository = nil
        sharingService = nil
        useCase = nil
    }
    
    func testShareList() async throws {
        let list = ShoppingList(name: "Groceries")
        try await listRepository.save(list)
        
        try await useCase.execute(listId: list.id, via: .iMessage)
        
        let sharedLists = await sharingService.sharedLists
        XCTAssertEqual(sharedLists.count, 1)
        XCTAssertEqual(sharedLists.first?.0.id, list.id)
        if case .iMessage = sharedLists.first?.1 {
            // Success
        } else {
            XCTFail("Should share via iMessage")
        }
    }
    
    func testShareNonexistentList() async throws {
        let nonexistentId = UUID()
        
        do {
            try await useCase.execute(listId: nonexistentId, via: .iMessage)
            XCTFail("Should throw list not found error")
        } catch UseCaseError.listNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
