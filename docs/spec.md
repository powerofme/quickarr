You are an expert Apple platform engineer and architect working inside a GitHub repository.

Build a Prototype 1 of an app called **Quickarr** – a smart shopping list manager – as a **universal app for both iOS and iPadOS**.

You must:
- Use **Swift + SwiftUI**.
- Support **iPhone and iPad** with adaptive layouts (size classes, multitasking on iPad, keyboard/trackpad where appropriate).
- Follow **Clean Architecture** with clear layers.
- Implement **Liquid Glass**-style design (latest Apple aesthetic using system materials, translucency, depth).
- Follow Apple’s latest **Human Interface Guidelines** for both iOS and iPadOS.
- Make all components **extendable** and cleanly separated for future versions.

==================================================
0. REPO & WORKFLOW EXPECTATIONS
==================================================

Inside this repo, you should:

- Create a clear folder structure, for example:
  - `Quickarr/Presentation/...`
  - `Quickarr/Domain/...`
  - `Quickarr/Data/...`
  - `Quickarr/Infrastructure/...`
  - `QuickarrTests/...`
- Prefer **small, focused files** and types with descriptive names.
- Add **Swift Package Manager** support if appropriate.
- Add **unit tests** for key domain logic and at least one sharing / category feature.
- Use descriptive commit messages when you modify multiple files (if you’re allowed to commit).
- When you respond in this workspace:
  - Show which files you created/modified.
  - Show the essential code snippets (not every line of boilerplate).
  - Maintain a short running checklist of TODOs in `docs/TODO-quickarr.md`.

==================================================
1. APP OVERVIEW & FEATURES
==================================================

App name: **Quickarr**

Goal: Smart shopping list management with:
- Intelligent item categorisation via public APIs.
- Sharing and updates via iMessage now.
- Clean abstraction for future REST-based sharing/sync.
- Great experience on **both iPhone and iPad**:
  - On iPhone: stacked, single-column navigation.
  - On iPad: make good use of large displays (e.g. sidebars, split views, multi-column layouts).

Prototype 1 must support:

1) **Create a new shopping list**
   - User can:
     - Create a list with a **name**.
     - Add line items.
   - For each item:
     - User types an item name.
     - The app automatically suggests a **category** using a public data source via REST APIs.
   - Category suggestion:
     - Implement a `CategorySuggestionService` abstraction in the Domain layer.
     - Data layer implementation calls a public API (or a placeholder endpoint), with:
       - Async call using `async/await`.
       - In-memory cache plus optional simple on-disk cache.
       - Graceful error handling and an `other` fallback category.

2) **Share shopping list via iMessage**
   - From a shopping list detail screen, user can share that list via iMessage.
   - The shared text should include:
     - List name.
     - Items grouped by category, and their current status if available.
   - Implement a **SharingService** abstraction:
     - Domain protocol with one method like:
       - `func share(list: ShoppingList, via channel: SharingChannel) async throws`
     - Data/Infrastructure implementation that:
       - Uses iOS/iPadOS share sheet / Messages support to prefill an iMessage.

3) **Start shopping (“pick a cart”) and send updates via iMessage**
   - On a list detail screen:
     - User can tap “Start Shopping” (picking a cart).
       - Create a `ShoppingSession` for that list.
   - For each item during a session, the user can:
     - **Mark as picked**.
     - **Mark as unavailable**.
     - **Select a substitute** (either by entering a new item or using same category).
   - Track per-item status:
     - `.pending`
     - `.picked`
     - `.unavailable`
     - `.substituted(substituteItem: SubstituteItem)`
   - Provide a button like **“Update sender via iMessage”**:
     - Compose a concise summary of:
       - Items picked.
       - Items unavailable.
       - Substitutes chosen.
     - Send via the same `SharingService` abstraction, e.g.:
       - `func sendUpdate(for session: ShoppingSession, via channel: SharingChannel) async throws`

4) **Future REST API sharing (design only for now)**
   - Do NOT implement a real backend.
   - Create **protocols and stubs** so a REST backend can be plugged in later:
     - `SharingRemoteAPI` with methods like:
       - `uploadList(list: ShoppingList)`
       - `syncUpdates(session: ShoppingSession)`
     - Provide a `MockRESTSharingService` or similar that logs calls or stores to a local dummy store.
   - Ensure `SharingService` can route based on `SharingChannel` (`.iMessage`, `.rest`, etc.).

==================================================
2. ARCHITECTURE & LAYERS
==================================================

Use **Clean Architecture** with clear separation:

- **Domain layer** (pure Swift, no framework types):
  - Entities:
    - `ShoppingList`
    - `ShoppingItem`
    - `ItemCategory` (enum, mappable from/to strings)
    - `ItemStatus` (enum: `.pending`, `.picked`, `.unavailable`, `.substituted(SubstituteItem)`)
    - `SubstituteItem`
    - `ShoppingSession`
    - `ShoppingChangeEvent`
  - Protocols:
    - `ShoppingListRepository`
    - `ShoppingSessionRepository`
    - `CategorySuggestionService`
    - `SharingService`
    - `SharingRemoteAPI` (for future REST)
  - Use cases (interactors), e.g.:
    - `CreateShoppingListUseCase`
    - `AddItemToListUseCase`
    - `UpdateItemStatusUseCase`
    - `StartShoppingSessionUseCase`
    - `GetActiveShoppingSessionsUseCase`
    - `ShareListUseCase`
    - `SendUpdateUseCase`
    - `SuggestCategoryForItemUseCase`
  - All domain logic must be testable without any iOS frameworks.

- **Data & Infrastructure layer**:
  - Implement repositories using **SwiftData** or **Core Data** (choose one and document in README).
  - Implement concrete `RemoteCategorySuggestionService`:
    - Uses `URLSession` internally.
    - Has a light caching layer.
  - Implement `iMessageSharingService`:
    - Bridges to UI via appropriate iOS/iPadOS APIs (share sheet, Messages).
  - Implement an initial stub for `SharingRemoteAPI` / REST sharing.

- **Presentation layer** (SwiftUI):
  - Use **MVVM** (View + ViewModel), or a light variant:
    - ViewModels depend only on Domain protocols, injected via initialisers.
  - SwiftUI Views:
    - Lists overview screen.
    - Create/Edit list screen.
    - List detail / shopping screen.
    - Optional: a simple “sessions” or “history” view.
  - Use `@Observable` or `ObservableObject` appropriately.
  - Make views adaptive for **iOS and iPadOS**:
    - Use size classes and `NavigationSplitView` or sidebars on iPad where appropriate.
    - Support multiwindow / multitasking on iPadOS where it’s simple to do so.
    - Ensure layouts look good in both portrait and landscape on iPad.

==================================================
3. UI, LAYOUTS & LIQUID GLASS DESIGN
==================================================

- Use **SwiftUI** with translucent system materials for Liquid Glass feel:
  - `Material.thin`, `Material.regular`, or newer equivalents.
  - Apply to:
    - Navigation bars / toolbars.
    - Bottom or side toolbars with primary actions (Start Shopping, Share).
    - Floating “Shopping session active” panel at top.
- Respect HIG for **both iOS and iPadOS**:
  - Use SF Symbols for icons (cart, list, share, etc.).
  - Support Dynamic Type, Dark Mode, and increased contrast.
  - On iPad:
    - Use larger screens efficiently:
      - Consider `NavigationSplitView` (sidebar with lists on the left, detail on the right).
      - Avoid overly stretched content; use columns, padding, and max-width constraints.
    - Optimise for keyboard and trackpad when possible (e.g., focus states, keyboard shortcuts for adding items in a later iteration).
- Screen patterns (adaptive):

1) **Shopping Lists Screen**
   - iPhone: standard navigation stack with a list.
   - iPad: sidebar list (possibly part of a `NavigationSplitView`).
   - Displays all `ShoppingList` entries.
   - Shows counts (e.g. “5 items · 3 picked”).
   - Floating “+” button or toolbar button to create new list.

2) **Create / Edit List Screen**
   - Text field for list name.
   - Item input:
     - User enters an item name.
     - On submit:
       - Call category suggestion use case.
       - Show inline category badge (“Dairy”, “Produce”, etc.).
   - Items displayed grouped by category.
   - On iPad, ensure the layout scales nicely:
     - Avoid full-width giant text fields; constrain content width and use cards or sections where appropriate.

3) **List Detail / Shopping Screen**
   - Sectioned list by category.
   - Each row:
     - Item name.
     - Category badge.
     - State indicator with quick controls:
       - Mark picked / unavailable / substitute.
   - “Start Shopping” button:
     - Activates a “session header” with Liquid Glass style.
   - “Share via iMessage” and “Send update” buttons:
     - On iPhone, likely in a bottom toolbar/floating panel.
     - On iPad, consider a bottom or side toolbar or a top-leading toolbar layout that fits with HIG.

==================================================
4. TESTING & DOCS
==================================================

- Add unit tests in `QuickarrTests` for:
  - `CreateShoppingListUseCase`.
  - `SuggestCategoryForItemUseCase` with a mocked `CategorySuggestionService`.
  - `ShareListUseCase` with a mocked `SharingService`.
- Optionally add a basic SwiftUI UI test for:
  - Creating a list.
  - Adding an item.
- Add a `README.md` that explains:
  - Architecture overview (Domain/Data/Presentation).
  - How to run the app.
  - iOS + iPadOS support:
    - Target platforms & minimum OS versions.
    - Notes about adaptive layouts (e.g. `NavigationSplitView` on iPad).
  - How to plug in a real REST backend later.
  - How Liquid Glass and HIG considerations were implemented.

==================================================
5. EXECUTION STRATEGY INSIDE THIS REPO
==================================================

Work in small, coherent steps:
1. Create / update **README.md** with a short spec summary including iOS + iPadOS support.
2. Scaffold the Xcode project (Quickarr app) and basic folder structure.
   - Ensure the target supports both iOS and iPadOS.
3. Implement **Domain layer** types and tests.
4. Implement **Data layer** (repositories, category suggestion, sharing stubs).
5. Implement **Presentation layer** (SwiftUI views + view models, Liquid Glass styling, adaptive layouts).
6. Wire dependencies through a simple composition root (e.g., in `QuickarrApp`).
7. Ensure the app builds and tests pass on both iOS and iPadOS simulators (conceptually).

In your responses:
- List the files you changed/created.
- Show the key code additions.
- Keep updating `docs/TODO-quickarr.md` with remaining tasks and checked-off items.
