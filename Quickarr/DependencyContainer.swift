//
//  DependencyContainer.swift
//  Quickarr
//
//  Dependency injection container
//

import Foundation
import SwiftData
import Observation

/// Container for managing app dependencies
@MainActor
@Observable
public class DependencyContainer {
    // Repositories
    public let listRepository: ShoppingListRepository
    public let sessionRepository: ShoppingSessionRepository
    
    // Services
    public let categorySuggestionService: CategorySuggestionService
    public let sharingService: SharingService
    
    // Use Cases
    public let createListUseCase: CreateShoppingListUseCase
    public let addItemUseCase: AddItemToListUseCase
    public let updateItemStatusUseCase: UpdateItemStatusUseCase
    public let startSessionUseCase: StartShoppingSessionUseCase
    public let getActiveSessionsUseCase: GetActiveShoppingSessionsUseCase
    public let shareListUseCase: ShareListUseCase
    public let sendUpdateUseCase: SendUpdateUseCase
    public let suggestCategoryUseCase: SuggestCategoryForItemUseCase
    
    public init(modelContainer: ModelContainer) {
        // Initialize repositories
        self.listRepository = SwiftDataShoppingListRepository(modelContainer: modelContainer)
        self.sessionRepository = SwiftDataShoppingSessionRepository(modelContainer: modelContainer)
        
        // Initialize services
        self.categorySuggestionService = RemoteCategorySuggestionService()
        
        let iMessageService = iMessageSharingService()
        let restService = MockRESTSharingService()
        self.sharingService = CompositeSharingService(
            iMessageService: iMessageService,
            restAPI: restService
        )
        
        // Initialize use cases
        self.createListUseCase = CreateShoppingListUseCase(repository: listRepository)
        self.addItemUseCase = AddItemToListUseCase(repository: listRepository)
        self.updateItemStatusUseCase = UpdateItemStatusUseCase(
            listRepository: listRepository,
            sessionRepository: sessionRepository
        )
        self.startSessionUseCase = StartShoppingSessionUseCase(
            sessionRepository: sessionRepository,
            listRepository: listRepository
        )
        self.getActiveSessionsUseCase = GetActiveShoppingSessionsUseCase(
            sessionRepository: sessionRepository
        )
        self.shareListUseCase = ShareListUseCase(
            listRepository: listRepository,
            sharingService: sharingService
        )
        self.sendUpdateUseCase = SendUpdateUseCase(
            sessionRepository: sessionRepository,
            listRepository: listRepository,
            sharingService: sharingService
        )
        self.suggestCategoryUseCase = SuggestCategoryForItemUseCase(
            categorySuggestionService: categorySuggestionService
        )
    }
}
