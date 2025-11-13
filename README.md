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
- iOS 17.0+ Simulator or Device
- Swift 5.9+

### Building the Project
1. Open `Quickarr.xcodeproj` in Xcode
2. Select a simulator or device (iPhone or iPad)
3. Press `Cmd+B` to build or `Cmd+R` to run

### Running Tests
- Press `Cmd+U` to run all unit tests
- Tests cover domain logic, use cases, and repository contracts

## Future Enhancements

The architecture is designed for extensibility:
- **REST Backend**: Protocols are ready for server-side list synchronization
- **Collaborative Shopping**: Multiple users can shop from the same list
- **Advanced Categorization**: ML-based category learning from user behavior
- **Recipe Integration**: Import ingredients from recipes
- **Store Integration**: Map items to specific store locations

## Contributing

This is a prototype demonstrating Clean Architecture and modern iOS development practices.

## License

TBD