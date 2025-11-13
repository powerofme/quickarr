//
//  ShoppingListsViewModel.swift
//  Quickarr
//
//  ViewModel for shopping lists overview
//

import Foundation
import Observation

@MainActor
@Observable
public class ShoppingListsViewModel {
    // State
    public private(set) var lists: [ShoppingList] = []
    public private(set) var activeSessions: [ShoppingSession] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    
    // Dependencies
    private let listRepository: ShoppingListRepository
    private let createListUseCase: CreateShoppingListUseCase
    private let getActiveSessionsUseCase: GetActiveShoppingSessionsUseCase
    
    public init(
        listRepository: ShoppingListRepository,
        createListUseCase: CreateShoppingListUseCase,
        getActiveSessionsUseCase: GetActiveShoppingSessionsUseCase
    ) {
        self.listRepository = listRepository
        self.createListUseCase = createListUseCase
        self.getActiveSessionsUseCase = getActiveSessionsUseCase
    }
    
    public func loadLists() async {
        isLoading = true
        errorMessage = nil
        
        do {
            lists = try await listRepository.fetchAll()
            activeSessions = try await getActiveSessionsUseCase.execute()
        } catch {
            errorMessage = "Failed to load lists: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    public func createList(name: String) async {
        errorMessage = nil
        
        do {
            _ = try await createListUseCase.execute(name: name)
            await loadLists()
        } catch {
            errorMessage = "Failed to create list: \(error.localizedDescription)"
        }
    }
    
    public func deleteList(id: UUID) async {
        errorMessage = nil
        
        do {
            try await listRepository.delete(id: id)
            await loadLists()
        } catch {
            errorMessage = "Failed to delete list: \(error.localizedDescription)"
        }
    }
    
    public func activeSession(forListId listId: UUID) -> ShoppingSession? {
        activeSessions.first { $0.listId == listId }
    }
}
