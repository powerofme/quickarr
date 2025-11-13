//
//  ListDetailViewModel.swift
//  Quickarr
//
//  ViewModel for shopping list detail and editing
//

import Foundation
import Observation

@MainActor
@Observable
public class ListDetailViewModel {
    // State
    public private(set) var list: ShoppingList
    public private(set) var activeSession: ShoppingSession?
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public var newItemName = ""
    public var newItemCategory: ItemCategory = .other
    
    // Dependencies
    private let listRepository: ShoppingListRepository
    private let sessionRepository: ShoppingSessionRepository
    private let addItemUseCase: AddItemToListUseCase
    private let updateItemStatusUseCase: UpdateItemStatusUseCase
    private let startSessionUseCase: StartShoppingSessionUseCase
    private let shareListUseCase: ShareListUseCase
    private let sendUpdateUseCase: SendUpdateUseCase
    private let suggestCategoryUseCase: SuggestCategoryForItemUseCase
    
    public init(
        list: ShoppingList,
        listRepository: ShoppingListRepository,
        sessionRepository: ShoppingSessionRepository,
        addItemUseCase: AddItemToListUseCase,
        updateItemStatusUseCase: UpdateItemStatusUseCase,
        startSessionUseCase: StartShoppingSessionUseCase,
        shareListUseCase: ShareListUseCase,
        sendUpdateUseCase: SendUpdateUseCase,
        suggestCategoryUseCase: SuggestCategoryForItemUseCase
    ) {
        self.list = list
        self.listRepository = listRepository
        self.sessionRepository = sessionRepository
        self.addItemUseCase = addItemUseCase
        self.updateItemStatusUseCase = updateItemStatusUseCase
        self.startSessionUseCase = startSessionUseCase
        self.shareListUseCase = shareListUseCase
        self.sendUpdateUseCase = sendUpdateUseCase
        self.suggestCategoryUseCase = suggestCategoryUseCase
    }
    
    public func loadList() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let updatedList = try await listRepository.fetch(id: list.id) {
                list = updatedList
            }
            
            // Check for active session
            let sessions = try await sessionRepository.fetchSessions(forListId: list.id)
            activeSession = sessions.first { $0.isActive }
        } catch {
            errorMessage = "Failed to load list: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    public func suggestCategoryForNewItem() async {
        guard !newItemName.isEmpty else { return }
        
        do {
            newItemCategory = try await suggestCategoryUseCase.execute(itemName: newItemName)
        } catch {
            newItemCategory = .other
        }
    }
    
    public func addItem() async {
        guard !newItemName.isEmpty else { return }
        
        errorMessage = nil
        
        do {
            let item = ShoppingItem(name: newItemName, category: newItemCategory)
            try await addItemUseCase.execute(item: item, toListId: list.id)
            newItemName = ""
            newItemCategory = .other
            await loadList()
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
        }
    }
    
    public func updateItemStatus(itemId: UUID, status: ItemStatus) async {
        errorMessage = nil
        
        do {
            try await updateItemStatusUseCase.execute(
                itemId: itemId,
                newStatus: status,
                inListId: list.id,
                sessionId: activeSession?.id
            )
            await loadList()
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }
    
    public func startShopping() async {
        errorMessage = nil
        
        do {
            activeSession = try await startSessionUseCase.execute(forListId: list.id)
            await loadList()
        } catch {
            errorMessage = "Failed to start shopping: \(error.localizedDescription)"
        }
    }
    
    public func endShopping() async {
        guard var session = activeSession else { return }
        
        errorMessage = nil
        
        do {
            session.end()
            try await sessionRepository.save(session)
            activeSession = nil
            await loadList()
        } catch {
            errorMessage = "Failed to end shopping: \(error.localizedDescription)"
        }
    }
    
    public func shareList() async {
        errorMessage = nil
        
        do {
            try await shareListUseCase.execute(listId: list.id, via: .iMessage)
        } catch {
            errorMessage = "Failed to share list: \(error.localizedDescription)"
        }
    }
    
    public func sendUpdate() async {
        guard let session = activeSession else { return }
        
        errorMessage = nil
        
        do {
            try await sendUpdateUseCase.execute(sessionId: session.id, via: .iMessage)
        } catch {
            errorMessage = "Failed to send update: \(error.localizedDescription)"
        }
    }
}
