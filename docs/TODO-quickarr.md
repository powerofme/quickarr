# Quickarr Implementation TODO

## Current Status: Phase 1 - Project Foundation

### Phase 1: Project Foundation ✅
- [x] Update README.md with comprehensive overview
- [x] Create TODO tracking document
- [x] Create Xcode project structure (universal iOS/iPadOS target)
- [x] Set up Clean Architecture folder structure

### Phase 2: Domain Layer Implementation
- [ ] Define core entities
  - [ ] ShoppingList
  - [ ] ShoppingItem
  - [ ] ItemCategory (enum)
  - [ ] ItemStatus (enum with associated values)
  - [ ] SubstituteItem
  - [ ] ShoppingSession
  - [ ] ShoppingChangeEvent
- [ ] Define domain protocols
  - [ ] ShoppingListRepository
  - [ ] ShoppingSessionRepository
  - [ ] CategorySuggestionService
  - [ ] SharingService
  - [ ] SharingRemoteAPI
- [ ] Implement use cases
  - [ ] CreateShoppingListUseCase
  - [ ] AddItemToListUseCase
  - [ ] UpdateItemStatusUseCase
  - [ ] StartShoppingSessionUseCase
  - [ ] GetActiveShoppingSessionsUseCase
  - [ ] ShareListUseCase
  - [ ] SendUpdateUseCase
  - [ ] SuggestCategoryForItemUseCase
- [ ] Add unit tests for domain layer

### Phase 3: Data & Infrastructure Layer
- [ ] Choose persistence strategy (SwiftData vs Core Data)
- [ ] Implement ShoppingListRepository
- [ ] Implement ShoppingSessionRepository
- [ ] Implement RemoteCategorySuggestionService
  - [ ] URLSession integration
  - [ ] In-memory cache
  - [ ] Optional disk cache
  - [ ] Error handling with fallback
- [ ] Implement iMessageSharingService
  - [ ] Share sheet integration
  - [ ] Message formatting
- [ ] Create SharingRemoteAPI stub for future REST
- [ ] Add tests for data layer

### Phase 4: Presentation Layer (SwiftUI + Liquid Glass)
- [ ] Set up dependency injection / composition root
- [ ] Shopping Lists Overview Screen
  - [ ] ViewModel
  - [ ] SwiftUI View (adaptive)
  - [ ] List display with counts
  - [ ] Create new list action
- [ ] Create/Edit List Screen
  - [ ] ViewModel with category suggestion
  - [ ] SwiftUI View (adaptive)
  - [ ] Item input with async category lookup
  - [ ] Grouped by category display
- [ ] List Detail/Shopping Screen
  - [ ] ViewModel with session management
  - [ ] SwiftUI View (adaptive)
  - [ ] Sectioned list by category
  - [ ] Item status controls
  - [ ] Start shopping button
  - [ ] Share and update actions
- [ ] Apply Liquid Glass design
  - [ ] System materials
  - [ ] Translucent backgrounds
  - [ ] SF Symbols
  - [ ] Dark mode support
- [ ] iPad-specific optimizations
  - [ ] NavigationSplitView implementation
  - [ ] Multitasking support
  - [ ] Keyboard shortcuts (optional)

### Phase 5: Integration & Testing
- [ ] Wire all dependencies in QuickarrApp
- [ ] Integration testing
- [ ] UI testing (optional)
- [ ] Test on iOS simulator
- [ ] Test on iPadOS simulator
- [ ] Final documentation polish

## Notes
- Using SwiftUI with iOS 17.0+ minimum target
- Clean Architecture ensures testability and maintainability
- iMessage sharing is primary sharing mechanism for Prototype 1
- REST API is designed but not implemented (stubs only)
