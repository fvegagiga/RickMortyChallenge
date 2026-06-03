---
description: SwiftUI presentation layer standards, best practices, and conventions for iOS Swift projects — including MVVM, ViewState, design system, navigation, reusable components, and UI testing practices.
globs: ["RickMortyPersistImage/Presentation/**/*.swift", "RickMortyPersistImage/Core/DesignSystem/**/*.swift", "RickMortyPersistImage/Core/Router/**/*.swift", "RickMortyPersistImageUITests/**/*.swift"]
alwaysApply: true
---

# SwiftUI Presentation Layer Standards

## Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
  - [MVVM Pattern](#mvvm-pattern)
  - [Feature Structure](#feature-structure)
- [ViewModels](#viewmodels)
  - [ViewState](#viewstate)
  - [ViewModel Rules](#viewmodel-rules)
- [SwiftUI Views](#swiftui-views)
  - [View Rules](#view-rules)
  - [Property Wrappers](#property-wrappers)
  - [Navigation](#navigation)
- [Reusable Components](#reusable-components)
- [Design System](#design-system)
  - [Colors](#colors)
  - [Spacing](#spacing)
  - [Typography](#typography)
- [Image Handling](#image-handling)
- [Coding Standards](#coding-standards)
  - [Naming Conventions](#naming-conventions)
  - [View Composition](#view-composition)
  - [Animations](#animations)
  - [Accessibility](#accessibility)
- [Testing Standards](#testing-standards)
  - [UI Tests with XCUITest](#ui-tests-with-xcuitest)
  - [SwiftUI Previews](#swiftui-previews)
- [Performance Best Practices](#performance-best-practices)

---

## Overview

This document defines standards for the Presentation layer of iOS Swift/SwiftUI projects. The layer follows MVVM with `ViewState<T>` for state management, `AppRouter` for navigation, and a centralized design system. All UI code must be written in SwiftUI; UIKit is only used indirectly (e.g., `UIImage` in the image cache).

## Technology Stack

- **SwiftUI**: Declarative UI framework for all views and components
- **Combine**: `@Published` properties in ViewModels; no manual publishers in Views
- **XCUITest**: End-to-end UI testing
- **SwiftUI Previews**: Live preview for components and screens during development

## Architecture Overview

### MVVM Pattern

```
View  ──(reads)──►  ViewState<T>  ──(published by)──►  ViewModel
  │                                                          │
  └──(calls async methods)──────────────────────────────────┘
                                     │
                              Use Case (injected)
```

- **View**: renders state, delegates all logic to ViewModel
- **ViewModel**: `@MainActor`, `ObservableObject`, owns `@Published` state
- **ViewState**: typed enum that drives the entire view lifecycle

### Feature Structure

Each feature lives under `Presentation/[Feature]/`:

```
Presentation/
├── Characters/
│   ├── ViewModels/
│   │   ├── CharactersListViewModel.swift
│   │   └── CharacterDetailViewModel.swift
│   └── Views/
│       ├── CharactersListView.swift
│       ├── CharacterDetailView.swift
│       └── CharacterCardView.swift
├── Episodes/
│   ├── ViewModels/
│   └── Views/
├── Locations/
│   ├── ViewModels/
│   └── Views/
├── Components/          # Shared reusable components
│   ├── ViewState.swift
│   ├── CachedAsyncImageView.swift
│   ├── LoadingView.swift
│   ├── ErrorView.swift
│   ├── EmptyStateView.swift
│   └── StatusBadgeView.swift
└── MainTabView.swift
```

## ViewModels

### ViewState

`ViewState<T>` is the single source of truth for screen state. Every screen uses it.

```swift
enum ViewState<T> {
    case idle       // Before any load has been requested
    case loading    // Fetch in progress
    case success(T) // Data available
    case empty      // Fetch succeeded but no items
    case failure(Error) // Fetch failed
}
```

Views switch exhaustively on `ViewState` — never use boolean flags like `isLoading: Bool` alongside it. The enum eliminates impossible states.

```swift
// Good: exhaustive switch, no extra flags
switch viewModel.viewState {
case .idle, .loading:
    LoadingView()
case .success(let characters):
    characterGrid(characters)
case .empty:
    EmptyStateView(icon: "person.slash", title: "No Characters Found", subtitle: "Try a different name.")
case .failure(let error):
    ErrorView(error: error) { Task { await viewModel.refresh() } }
}

// Avoid: boolean flags alongside ViewState
if viewModel.isLoading { ... }
if viewModel.hasError { ... }
```

### ViewModel Rules

```swift
@MainActor
final class CharactersListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[CharacterEntity]> = .idle
    @Published private(set) var isLoadingMore = false
    @Published var searchText = ""         // Two-way only for search/filter inputs

    private let getCharactersUseCase: GetCharactersUseCaseProtocol

    init(getCharactersUseCase: GetCharactersUseCaseProtocol) {
        self.getCharactersUseCase = getCharactersUseCase
    }
}
```

Rules:
- **`@MainActor`**: every ViewModel is `@MainActor` — all `@Published` mutations happen on the main thread automatically
- **`final`**: ViewModels are always `final` — they are not subclassed
- **`private(set)`**: all `@Published` properties except user-input fields are `private(set)` — views only read, never write state directly
- **Inject via protocol**: inject use cases through the constructor — never instantiate them inside the ViewModel
- **No `DIContainer` in ViewModels**: ViewModels don't know about `DIContainer`; factories in `DIContainer` wire them up
- **Task management**: cancel debounce/search tasks on `deinit` or before starting new ones

```swift
// Debounce pattern for search
private var searchDebounceTask: Task<Void, Never>?

func onSearchTextChanged() {
    searchDebounceTask?.cancel()
    searchDebounceTask = Task {
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard !Task.isCancelled else { return }
        await performSearch()
    }
}
```

## SwiftUI Views

### View Rules

- Views are `struct` — always value types
- Views contain **no business logic** — they call ViewModel methods and render state
- Extract complex subviews into `@ViewBuilder` computed properties or separate `View` structs
- Keep `body` under ~30 lines; extract beyond that

```swift
struct CharactersListView: View {
    @StateObject private var viewModel: CharactersListViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var container: DIContainer

    var body: some View {
        NavigationStack(path: $router.characterPath) {
            contentView
                .navigationTitle("Characters")
                .task { await viewModel.loadInitial() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading: LoadingView()
        case .success(let items): characterGrid(items)
        case .empty: EmptyStateView(...)
        case .failure(let error): ErrorView(error: error) { ... }
        }
    }
}
```

### Property Wrappers

| Wrapper | Use case |
|---|---|
| `@StateObject` | ViewModel owned by this view — root ownership |
| `@ObservedObject` | ViewModel passed in from parent — not owned |
| `@EnvironmentObject` | Shared singletons: `AppRouter`, `DIContainer` |
| `@State` | Local ephemeral UI state (sheet presented, selected tab) |
| `@Binding` | Two-way state passed down from parent |
| `@Environment` | System values: `\.colorScheme`, `\.dismiss` |

Never use `@ObservedObject` for a ViewModel the view creates — that would lose the object on re-renders. Use `@StateObject` when the view owns the ViewModel.

### Navigation

Navigation uses `AppRouter` with typed route enums and `NavigationStack`.

```swift
// Route definition (in AppRouter.swift)
enum CharacterRoute: Hashable {
    case detail(id: Int)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var characterPath = NavigationPath()

    func pushCharacter(_ route: CharacterRoute) {
        characterPath.append(route)
    }
}

// Usage in view
Button { router.pushCharacter(.detail(id: character.id)) } label: { ... }

// Destination registration
.navigationDestination(for: CharacterRoute.self) { route in
    switch route {
    case .detail(let id):
        CharacterDetailView(viewModel: container.makeCharacterDetailViewModel(id: id))
    }
}
```

Rules:
- All navigation is driven by `AppRouter` — never use `NavigationLink(destination:)` with inline view construction
- New features add their route enum and push method to `AppRouter`
- Never push navigation from ViewModel — navigation is always triggered by user actions in the View

## Reusable Components

Shared components live in `Presentation/Components/`. Never duplicate their logic.

### `LoadingView`
Full-screen centered `ProgressView` with the portal green tint. Use for `.idle` and `.loading` states.

### `ErrorView`
Displays an error message with a retry button. Accepts an `Error` and a retry closure.

```swift
ErrorView(error: error) {
    Task { await viewModel.refresh() }
}
```

### `EmptyStateView`
Displays an SF Symbol icon, title, and subtitle. Use for `.empty` state.

```swift
EmptyStateView(
    icon: "person.slash",
    title: "No Characters Found",
    subtitle: "Try a different name."
)
```

### `StatusBadgeView`
Colored pill badge for character alive/dead/unknown status. Uses `Color.DS` semantic colors.

### `CachedAsyncImageView`
Two-level cached image (NSCache + disk). **Always** use this instead of `AsyncImage`.

```swift
CachedAsyncImageView(url: character.imageURL, cacheManager: container.imageCacheManager) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Color.DS.cardBackground
}
```

## Design System

Never hardcode colors, spacing values, or font sizes inline. Always use the design system tokens.

### Colors

Colors live in `Core/DesignSystem/DSColors.swift` as `Color.DS` static properties:

```swift
Color.DS.portalGreen      // Primary brand / accent
Color.DS.portalGreenDim   // Dimmed variant for pressed states
Color.DS.statusAlive      // CharacterStatus.alive indicator
Color.DS.statusDead       // CharacterStatus.dead indicator
Color.DS.statusUnknown    // CharacterStatus.unknown indicator
Color.DS.cardBackground   // List/grid card background
Color.DS.surfacePrimary   // Screen background
Color.DS.textPrimary      // Primary label
Color.DS.textSecondary    // Secondary label
Color.DS.textTertiary     // Tertiary label
Color.DS.separator        // Dividers and borders
```

Dark mode is handled automatically via system semantic colors (`Color(.systemBackground)`, etc.) — no manual color scheme checks needed.

### Spacing

Spacing lives in `Core/DesignSystem/DSSpacing.swift`:

```swift
DSSpacing.xs   // 4
DSSpacing.sm   // 8
DSSpacing.md   // 16
DSSpacing.lg   // 24
DSSpacing.xl   // 32
```

```swift
// Good
.padding(.horizontal, DSSpacing.md)

// Avoid
.padding(.horizontal, 16)
```

### Typography

Typography lives in `Core/DesignSystem/DSTypography.swift`. Use the defined text styles for consistent hierarchy.

## Image Handling

- **Always use `CachedAsyncImageView`** — never `AsyncImage` directly
- Pass `container.imageCacheManager` from the environment — never create a new `ImageCacheManager` in a view
- Use `.task(id: url)` for loading to automatically cancel and restart when the URL changes
- Provide a placeholder with `Color.DS.cardBackground` so the grid layout is stable before images load

## Coding Standards

### Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Views | PascalCase + `View` suffix | `CharactersListView`, `CharacterCardView` |
| ViewModels | PascalCase + `ViewModel` suffix | `CharactersListViewModel` |
| Components | PascalCase + `View` suffix | `LoadingView`, `ErrorView` |
| `@ViewBuilder` properties | camelCase, noun | `contentView`, `characterGrid` |
| Action handlers | camelCase, verb phrase | `onRetryTapped`, `onSearchTextChanged` |
| Route enums | PascalCase + `Route` suffix | `CharacterRoute`, `LocationRoute` |

### View Composition

Break views into smaller pieces using `@ViewBuilder` private properties or private structs:

```swift
// Good: extracted subview
@ViewBuilder
private var characterGrid: some View { ... }

// Good: extracted component struct
private struct CharacterCardView: View { ... }

// Avoid: deeply nested body with 100+ lines
var body: some View {
    VStack {
        HStack { ... lots of code ... }
        ForEach { ... lots of code ... }
    }
}
```

Prefer `@ViewBuilder` private properties for simple extractions within the same file. Create a separate struct file when the component is reused across features.

### Animations

- Use `animation(_:value:)` with a specific value — never `withAnimation {}` for data-driven changes
- Use `transition(.asymmetric(...))` for list insertions/removals
- Prefer `.spring(response:dampingFraction:)` over `.easeInOut` for interactive feel

```swift
.animation(.spring(response: 0.45, dampingFraction: 0.8), value: characters.map(\.id))
```

### Accessibility

- All interactive elements need `.accessibilityLabel` when the visual label is non-obvious
- `Button` labels must be descriptive: `"View \(character.name) details"`, not `"Tap"`
- `Image` with informational content needs `.accessibilityLabel`; decorative images use `.accessibilityHidden(true)`
- Minimum tap target: 44×44 pt — use `.frame(minWidth: 44, minHeight: 44)` for small controls

## Testing Standards

### UI Tests with XCUITest

UI tests live in `RickMortyPersistImageUITests/`. They test real navigation flows against the running app.

```swift
final class CharactersListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCharactersList_displaysCharacters() {
        let collectionView = app.scrollViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
    }
}
```

Rules:
- Add `accessibilityIdentifier` to key interactive elements to make them reliably selectable in tests
- Never hardcode sleep waits — use `waitForExistence(timeout:)` 
- UI tests cover navigation flows, not pixel-perfect layout

### SwiftUI Previews

Every view and reusable component must have a `#Preview` (or `PreviewProvider` for older targets):

```swift
#Preview {
    CharacterCardView(character: MockDataFactory.makeCharacterEntity(), cacheManager: MockImageCacheManager())
        .padding()
}

#Preview("Empty State") {
    EmptyStateView(icon: "person.slash", title: "No Results", subtitle: "Try again.")
}
```

Rules:
- Provide previews for all notable states (loading, success, empty, error)
- Use `MockDataFactory` to supply realistic preview data — never hardcode strings in previews
- Name previews descriptively when showing a specific state

## Performance Best Practices

- **`LazyVGrid` / `LazyVStack`**: always use lazy containers for lists — never `VStack` + `ForEach` for unbounded data
- **`.task(id:)`**: use the `id` parameter to cancel and restart async work when a dependency changes (e.g., URL)
- **Avoid re-renders**: only `@Published` properties that the view actually reads should be in the ViewModel — split into multiple ViewModels if a view reads only a subset of a large model
- **`@StateObject` vs `@ObservedObject`**: use `@StateObject` for ViewModels the view creates; use `@ObservedObject` for ones passed in — getting this wrong causes random re-initialization
- **Image loading**: `CachedAsyncImageView` uses a two-level cache (memory + disk) — never bypass it by loading images manually in a view
