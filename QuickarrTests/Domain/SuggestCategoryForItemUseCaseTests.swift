//
//  SuggestCategoryForItemUseCaseTests.swift
//  QuickarrTests
//
//  Tests for SuggestCategoryForItemUseCase
//

import XCTest
@testable import Quickarr

final class SuggestCategoryForItemUseCaseTests: XCTestCase {
    var service: MockCategorySuggestionService!
    var useCase: SuggestCategoryForItemUseCase!
    
    override func setUp() async throws {
        service = MockCategorySuggestionService()
        useCase = SuggestCategoryForItemUseCase(categorySuggestionService: service)
    }
    
    override func tearDown() async throws {
        await service.reset()
        service = nil
        useCase = nil
    }
    
    func testSuggestCategory() async throws {
        await service.setMockSuggestion(itemName: "milk", category: .dairy)
        
        let category = try await useCase.execute(itemName: "Milk")
        
        XCTAssertEqual(category, .dairy)
    }
    
    func testSuggestCategoryDefault() async throws {
        let category = try await useCase.execute(itemName: "Unknown Item")
        
        XCTAssertEqual(category, .other)
    }
    
    func testEmptyItemName() async throws {
        do {
            _ = try await useCase.execute(itemName: "")
            XCTFail("Should throw invalid input error")
        } catch UseCaseError.invalidInput {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
