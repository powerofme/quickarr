# Quickarr Implementation TODO

## Current Status: Phase 1 - Project Foundation

### Phase 1: Project Foundation ✅
- [x] Update README.md with comprehensive overview
- [x] Create TODO tracking document
- [x] Create Xcode project structure (universal iOS/iPadOS target)
- [x] Set up Clean Architecture folder structure

### Phase 2: Domain Layer Implementation ✅
- [x] Define core entities
  - [x] ShoppingList
  - [x] ShoppingItem
  - [x] ItemCategory (enum)
  - [x] ItemStatus (enum with associated values)
  - [x] SubstituteItem
  - [x] ShoppingSession
  - [x] ShoppingChangeEvent
- [x] Define domain protocols
  - [x] ShoppingListRepository
  - [x] ShoppingSessionRepository
  - [x] CategorySuggestionService
  - [x] SharingService
  - [x] SharingRemoteAPI
- [x] Implement use cases
  - [x] CreateShoppingListUseCase
  - [x] AddItemToListUseCase
  - [x] UpdateItemStatusUseCase
  - [x] StartShoppingSessionUseCase
  - [x] GetActiveShoppingSessionsUseCase
  - [x] ShareListUseCase
  - [x] SendUpdateUseCase
  - [x] SuggestCategoryForItemUseCase
- [x] Add unit tests for domain layer

### Phase 3: Data & Infrastructure Layer ✅
- [x] Choose persistence strategy (SwiftData)
- [x] Implement ShoppingListRepository (SwiftData)
- [x] Implement ShoppingSessionRepository (SwiftData)
- [x] Implement RemoteCategorySuggestionService
  - [x] URLSession integration
  - [x] In-memory cache
  - [x] Error handling with fallback (heuristic)
- [x] Implement iMessageSharingService
  - [x] Share sheet integration
  - [x] Message formatting
- [x] Create SharingRemoteAPI stub for future REST
- [x] Create CompositeSharingService for routing

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
