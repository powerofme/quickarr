# Quickarr

**A smart shopping list manager for iOS and iPadOS**

Quickarr is a universal app that helps you create, manage, and share shopping lists with intelligent category suggestions and real-time updates via iMessage.

## Features (Prototype 1)

- **Smart Shopping Lists**: Create lists with automatic item categorization via public APIs
- **iMessage Integration**: Share lists and send shopping updates directly through iMessage
- **Shopping Sessions**: Track items as picked, unavailable, or substituted during shopping
- **Universal App**: Optimized for both iPhone and iPad with adaptive layouts
- **Liquid Glass Design**: Modern iOS aesthetic using system materials and translucency

## Architecture

Quickarr follows **Clean Architecture** principles with clear separation of concerns:

### Domain Layer (`Quickarr/Domain/`)
Pure Swift business logic with no framework dependencies:
- **Entities**: `ShoppingList`, `ShoppingItem`, `ItemCategory`, `ItemStatus`, `ShoppingSession`, etc.
- **Protocols**: `ShoppingListRepository`, `CategorySuggestionService`, `SharingService`, `SharingRemoteAPI`
- **Use Cases**: `CreateShoppingListUseCase`, `AddItemToListUseCase`, `ShareListUseCase`, etc.

### Data & Infrastructure Layer (`Quickarr/Data/`, `Quickarr/Infrastructure/`)
Concrete implementations:
- **Persistence**: SwiftData-based repositories for local storage
- **Category Suggestion**: REST API client with caching for item categorization
- **Sharing**: iMessage integration via iOS share sheet APIs
- **Future REST API**: Protocol stubs for future backend synchronization

### Presentation Layer (`Quickarr/Presentation/`)
SwiftUI views with MVVM pattern:
- **Shopping Lists Screen**: Browse and manage all lists
- **Create/Edit Screen**: Add items with automatic category suggestions
- **Shopping Session Screen**: Track item status during shopping with update capabilities
- All views are adaptive for iPhone and iPad with `NavigationSplitView` on larger screens

## Platform Support

- **Target Platforms**: iOS 17.0+, iPadOS 17.0+
- **Universal App**: Single binary runs natively on iPhone and iPad
- **Adaptive Layouts**: 
  - iPhone: Stack-based navigation
  - iPad: Split-view layouts, sidebar navigation, optimized for larger displays
- **Multitasking**: Full iPad multitasking support
- **Input Methods**: Touch, keyboard, and trackpad on iPad
- **Accessibility**: Dynamic Type, Dark Mode, VoiceOver support

## Design Philosophy

**Liquid Glass Aesthetic** following Apple's latest Human Interface Guidelines:
- System materials (`.thin`, `.regular`) for translucent backgrounds
- Depth and layering with shadows and blur effects
- SF Symbols for consistent iconography
- Adaptive color schemes (Light/Dark mode)
- Smooth animations and transitions

## Project Structure

```
Quickarr/
├── Domain/
│   ├── Entities/
│   ├── Protocols/
│   └── UseCases/
├── Data/
│   ├── Repositories/
│   └── Services/
├── Infrastructure/
│   ├── Network/
│   └── Persistence/
└── Presentation/
    ├── ViewModels/
    └── Views/
QuickarrTests/
└── Domain/
```

## Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.0+ / iPadOS 17.0+ Simulator or Device
- Swift 5.9+

### Building the Project

#### Using Xcode
1. Clone the repository:
   ```bash
   git clone https://github.com/powerofme/quickarr.git
   cd quickarr
   ```

2. Open in Xcode:
   - Double-click `Package.swift` to open in Xcode
   - Or use `xed .` from the command line

3. Select target device:
   - Choose iPhone simulator for phone experience
   - Choose iPad simulator for tablet experience with split-view layout

4. Build and run:
   - Press `Cmd+R` to build and run
   - Press `Cmd+B` to just build

#### Using Swift Package Manager (CLI)
```bash
swift build
swift test
```

### Running Tests
- **In Xcode**: Press `Cmd+U` to run all unit tests
- **Command line**: `swift test`
- Tests cover:
  - Domain entities and business logic
  - Use cases with mocked dependencies
  - Repository contracts

### App Features Walkthrough

1. **Create a Shopping List**
   - Tap the "+" button to create a new list
   - Enter a name and tap "Create"

2. **Add Items to List**
   - Open a list and type an item name
   - The app automatically suggests a category
   - Tap the "+" icon or press Return to add

3. **Start Shopping**
   - Tap "Start Shopping" to begin a shopping session
   - Mark items as picked, unavailable, or substituted
   - Track your progress in real-time

4. **Share and Update**
   - Tap "Share" to send the list via iMessage
   - While shopping, tap "Send Update" to share progress
   - Recipients get formatted messages with item status

## Future Enhancements

The architecture is designed for extensibility:

### Planned Features
- **REST Backend**: Protocols are ready for server-side list synchronization
  - `SharingRemoteAPI` interface defined
  - `MockRESTSharingService` demonstrates integration pattern
  - Easy to swap with real API client
  
- **Collaborative Shopping**: Multiple users can shop from the same list
  - Session tracking infrastructure in place
  - Update broadcasting via REST API ready to implement
  
- **Advanced Categorization**: ML-based category learning from user behavior
  - Current fallback categorization provides baseline
  - Can integrate Core ML models for personalized suggestions
  
- **Recipe Integration**: Import ingredients from recipes
  - Item data structure supports metadata
  - Easy to add recipe source tracking
  
- **Store Integration**: Map items to specific store locations
  - Category system provides foundation
  - Can extend with store-specific data

### Technical Improvements
- Enhanced caching strategies for offline support
- More sophisticated state management for complex workflows
- Additional UI optimizations for large lists
- Keyboard shortcuts for iPad productivity
- Handoff support between devices

## Implementation Notes

### Persistence Strategy
The app uses **SwiftData** (iOS 17+) for local data persistence:
- `ShoppingListModel` for lists and items
- `ShoppingSessionModel` for shopping sessions
- JSON encoding for complex nested data (items, status snapshots)
- Automatic sync with SwiftUI views via `@Model` macro

### Category Suggestion
The `RemoteCategorySuggestionService` implements:
1. **In-memory caching** with 1-hour TTL
2. **Fallback heuristics** when API unavailable
3. **Parallel batch processing** for multiple items
4. **Graceful error handling** with sensible defaults

Currently uses heuristic-based categorization. To integrate a real API:
```swift
// In RemoteCategorySuggestionService.swift
private func fetchFromRemote(itemName: String) async throws -> ItemCategory {
    // Replace with actual API call
    let url = URL(string: "\(baseURL)?item=\(itemName)")!
    let (data, _) = try await urlSession.data(from: url)
    // Parse response and return category
}
```

### iMessage Sharing
The `iMessageSharingService` uses iOS `UIActivityViewController`:
- Formats lists and updates as readable text
- Presents native iOS share sheet
- Optimized for iPad (popover presentation)
- Falls back gracefully on unsupported platforms

### Clean Architecture Benefits
1. **Testability**: Domain logic independent of frameworks
2. **Flexibility**: Easy to swap implementations
3. **Maintainability**: Clear separation of concerns
4. **Scalability**: Add features without touching existing code

### iOS/iPadOS Adaptivity
The UI adapts to different form factors:
- **iPhone**: Stack-based navigation
- **iPad**: Can use split-view layouts (infrastructure ready)
- **Size classes**: Responsive to multitasking modes
- **Dynamic Type**: Supports accessibility text sizing
- **Dark Mode**: Full support via system materials

## Contributing

This is a prototype demonstrating Clean Architecture and modern iOS development practices.

## License

TBD