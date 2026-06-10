---
description: SwiftUI presentation layer standards, best practices, and conventions for iOS Swift projects — including MVVM, ViewState, design system, navigation, reusable components, and UI testing practices.
globs: ["**/*.swift"]
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

This document defines standards for the Presentation layer of iOS Swift/SwiftUI projects. The layer follows MVVM with a typed `ViewState<T>` for screen state, a single navigation strategy, and a centralized design system. All UI code must be written in SwiftUI; UIKit is only used indirectly (e.g., `UIImage` in an image cache).

> Conventions: throughout this guide, replace the placeholders with your project's real names:
> `<AppName>` is the app/target/scheme, `<AppName>UITests` is the UI test target,
> `<Feature>` is a feature/screen group (for example `Products`, `Orders`), and
> `<Entity>` is the domain entity rendered by that feature.

> **Generic vs project-specific (two-tier model).** This guide defines *principles* and *roles*.
> The *concrete choices* for a given project — state-management approach (`@Observable` vs
> `ObservableObject`), navigation strategy, design-token names, image handling, and minimum
> deployment target — live in **`docs/project-profile.md`**. Concrete type names below (for example
> `AppRouter`, `Color.DS.*`, `CachedAsyncImageView`) are *illustrative examples* of a role; the
> binding decision for your project is whatever `project-profile.md` records. The `adapt-standards`
> skill fills in that profile and prunes sections that do not apply.

## Technology Stack

- **SwiftUI**: Declarative UI framework for all views and components
- **State management**: the **Observation** framework (`@Observable`, iOS 17+) for new projects,
  or `ObservableObject` + Combine `@Published` for older deployment targets
  (see [ViewModel Rules](#viewmodel-rules))
- **XCTest / Swift Testing**: unit testing; **XCUITest** for end-to-end UI flows
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
- **ViewModel**: `@MainActor`, observable (`@Observable` or `ObservableObject`), owns the state
- **ViewState**: typed enum that drives the entire view lifecycle

### Feature Structure

Each feature lives under `Presentation/[Feature]/`. The component file names below are
illustrative (see `docs/project-profile.md` for the project's actual set):

```
Presentation/
├── <FeatureA>/
│   ├── ViewModels/
│   │   ├── <FeatureA>ListViewModel.swift
│   │   └── <FeatureA>DetailViewModel.swift
│   └── Views/
│       ├── <FeatureA>ListView.swift
│       ├── <FeatureA>DetailView.swift
│       └── <FeatureA>CardView.swift
├── <FeatureB>/
│   ├── ViewModels/
│   └── Views/
├── <FeatureC>/
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
case .success(let items):
    itemGrid(items)
case .empty:
    EmptyStateView(icon: "magnifyingglass", title: "No <Feature> Found", subtitle: "Try a different name.")
case .failure(let error):
    ErrorView(error: error) { Task { await viewModel.refresh() } }
}

// Avoid: boolean flags alongside ViewState
if viewModel.isLoading { ... }
if viewModel.hasError { ... }
```

### ViewModel Rules

Choose **one** state-management approach per project and stay consistent — record the choice in
`docs/project-profile.md`. New projects on iOS 17+ default to Option A (`@Observable`); older
deployment targets use Option B (`ObservableObject`). **Every view example in this guide must be
read through the lens of the chosen option** (property wrappers differ — see the mapping table in
[Property Wrappers](#property-wrappers)).

> **Binding for this project**: Option B (`ObservableObject` + `@Published`) is the current
> implementation. iOS 17 is now the deployment target, so **Option A (`@Observable`) is the
> recommended migration target** for new ViewModels and refactors. Use `@StateObject` /
> `@EnvironmentObject` in existing code until migrated.

**Option A — Observation framework (`@Observable`, iOS 17+, preferred for new projects):**

> *Not used in this project — migration reference only.*

```swift
import Observation

@MainActor
@Observable
final class <Feature>ListViewModel {
    private(set) var viewState: ViewState<[<Entity>Entity]> = .idle
    private(set) var isLoadingMore = false
    var searchText = ""                    // Two-way only for search/filter inputs

    @ObservationIgnored
    private let get<Entity>ListUseCase: Get<Entity>ListUseCaseProtocol

    init(get<Entity>ListUseCase: Get<Entity>ListUseCaseProtocol) {
        self.get<Entity>ListUseCase = get<Entity>ListUseCase
    }
}
```

With `@Observable`, the view owns the ViewModel via `@State` (not `@StateObject`), shared
instances are injected with `@Environment` (not `@EnvironmentObject`), and dependencies that are
not observable state are marked `@ObservationIgnored`.

**Option B — `ObservableObject` + Combine (older deployment targets):**

> *Binding for this project — follow this option in all new Presentation layer code.*

```swift
@MainActor
final class <Feature>ListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[<Entity>Entity]> = .idle
    @Published private(set) var isLoadingMore = false
    @Published var searchText = ""         // Two-way only for search/filter inputs

    private let get<Entity>ListUseCase: Get<Entity>ListUseCaseProtocol

    init(get<Entity>ListUseCase: Get<Entity>ListUseCaseProtocol) {
        self.get<Entity>ListUseCase = get<Entity>ListUseCase
    }
}
```

Rules (apply to both options):
- **`@MainActor`**: every ViewModel is `@MainActor` — all state mutations happen on the main thread automatically
- **`final`**: ViewModels are always `final` — they are not subclassed
- **`private(set)`**: all observed properties except user-input fields are `private(set)` — views only read, never write state directly
- **Inject via protocol**: inject use cases through the constructor — never instantiate them inside the ViewModel
- **No composition root in ViewModels**: ViewModels don't know about the DI container/composition root; factories there wire them up and inject only the use cases they need
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

The example below uses **Option A (`@Observable`)** wrappers by default in the generic guide.
**This project uses Option B** — swap per the [Property Wrappers](#property-wrappers) table
(`@State` → `@StateObject`, `@Environment` → `@EnvironmentObject`). `router` and `container` are
the project's navigation and composition-root roles (names per `docs/project-profile.md`).

```swift
struct <Feature>ListView: View {
    @State private var viewModel: <Feature>ListViewModel
    @Environment(AppRouter.self) private var router
    @Environment(DIContainer.self) private var container

    var body: some View {
        NavigationStack(path: $router.<feature>Path) {
            contentView
                .navigationTitle("<Feature>")
                .task { await viewModel.loadInitial() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading: LoadingView()
        case .success(let items): itemGrid(items)
        case .empty: EmptyStateView(...)
        case .failure(let error): ErrorView(error: error) { ... }
        }
    }
}
```

### Property Wrappers

With `ObservableObject` (Option B):

| Wrapper | Use case |
|---|---|
| `@StateObject` | ViewModel owned by this view — root ownership |
| `@ObservedObject` | ViewModel passed in from parent — not owned |
| `@EnvironmentObject` | Shared singletons: `AppRouter`, `DIContainer` |
| `@State` | Local ephemeral UI state (sheet presented, selected tab) |
| `@Binding` | Two-way state passed down from parent |
| `@Environment` | System values: `\.colorScheme`, `\.dismiss` |

Never use `@ObservedObject` for a ViewModel the view creates — that would lose the object on re-renders. Use `@StateObject` when the view owns the ViewModel.

With the Observation framework (`@Observable`, Option A), the mapping changes:

| ObservableObject | `@Observable` equivalent |
|---|---|
| `@StateObject var vm` | `@State var vm` (view owns it) |
| `@ObservedObject var vm` | plain `let vm` / `var vm` (passed in) |
| `@EnvironmentObject var x` | `@Environment(X.self) var x` |
| `@Published var value` | a plain stored property (observed automatically) |

`@State`, `@Binding`, and `@Environment` (system values) work the same in both worlds.

### Navigation

Navigation uses **typed routes** (`Hashable` enums) driven through `NavigationStack`, centralized
in a single navigation strategy. The *concrete* strategy is the project's choice (recorded in
`docs/project-profile.md`): a lightweight router object, native per-stack `NavigationPath` state, a
coordinator pattern, or a framework-provided router. Whatever the strategy, the principles are the
same — routes are typed values, destinations are registered with `.navigationDestination(for:)`,
and inline `NavigationLink(destination:)` view construction is avoided.

The example below shows one common shape (a lightweight router object):

```swift
// Route definition — typed, Hashable
enum <Feature>Route: Hashable {
    case detail(id: Int)
}

// Example navigation strategy (role: owns navigation state, exposes intent-named push methods)
@MainActor
final class AppRouter {
    var <feature>Path = NavigationPath()

    func push<Feature>(_ route: <Feature>Route) {
        <feature>Path.append(route)
    }
}

// Usage in view
Button { router.push<Feature>(.detail(id: item.id)) } label: { ... }

// Destination registration
.navigationDestination(for: <Feature>Route.self) { route in
    switch route {
    case .detail(let id):
        <Feature>DetailView(viewModel: container.make<Feature>DetailViewModel(id: id))
    }
}
```

Rules:
- All navigation is driven by the project's navigation strategy — never use
  `NavigationLink(destination:)` with inline view construction
- New features add their typed route enum and a push method to that strategy
- Never push navigation from a ViewModel — navigation is always triggered by user actions in the View

## Reusable Components

Shared components live in `Presentation/Components/`. Never duplicate their logic. The components
below are an **illustrative set** that most apps end up needing — the actual names and which ones
exist are recorded in `docs/project-profile.md`. The principle is: every recurring UI pattern
(loading, error, empty, status, cached image…) has exactly one reusable component.

### `LoadingView`
Full-screen centered `ProgressView` with the brand accent tint. Use for `.idle` and `.loading` states.

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
    icon: "magnifyingglass",
    title: "No <Feature> Found",
    subtitle: "Try a different name."
)
```

### `StatusBadgeView`
Colored pill badge for an entity's status (e.g., active/inactive/unknown). Uses `Color.DS` semantic colors.

### `CachedAsyncImageView`
Two-level cached image (NSCache + disk). Use this instead of `AsyncImage` when loading remote images that benefit from caching.

```swift
CachedAsyncImageView(url: item.imageURL, cacheManager: container.imageCacheManager) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Color.DS.cardBackground
}
```

## Design System

Never hardcode colors, spacing values, or font sizes inline. Always use the design system tokens.
The token *namespace* and exact token names are the project's choice (recorded in
`docs/project-profile.md`); the examples below (`Color.DS.*`, `DSSpacing`, `DSTypography`) show one
common convention. The non-negotiable principle is: **all visual constants come from named tokens,
never inline literals.**

### Colors

Example: colors live in `Core/DesignSystem/DSColors.swift` as `Color.DS` static properties:

```swift
Color.DS.brandPrimary     // Primary brand / accent
Color.DS.brandPrimaryDim  // Dimmed variant for pressed states
Color.DS.statusActive     // Status indicator (e.g., active)
Color.DS.statusInactive   // Status indicator (e.g., inactive)
Color.DS.statusUnknown    // Status indicator (e.g., unknown)
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

> Applies only when the app loads remote images. Skip this section (and the image-caching role)
> if your UI uses only local/asset images.

- **Use the project's cached image component for remote images** (role: `CachedAsyncImageView`) —
  prefer it over `AsyncImage` directly when caching matters
- Pass the shared image cache from the environment — never create a new cache instance in a view
- Use `.task(id: url)` for loading to automatically cancel and restart when the URL changes
- Provide a placeholder from a design token so the layout is stable before images load

## Coding Standards

### Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Views | PascalCase + `View` suffix | `<Feature>ListView`, `<Feature>CardView` |
| ViewModels | PascalCase + `ViewModel` suffix | `<Feature>ListViewModel` |
| Components | PascalCase + `View` suffix | `LoadingView`, `ErrorView` |
| `@ViewBuilder` properties | camelCase, noun | `contentView`, `itemGrid` |
| Action handlers | camelCase, verb phrase | `onRetryTapped`, `onSearchTextChanged` |
| Route enums | PascalCase + `Route` suffix | `<FeatureA>Route`, `<FeatureB>Route` |

### View Composition

Break views into smaller pieces using `@ViewBuilder` private properties or private structs:

```swift
// Good: extracted subview
@ViewBuilder
private var itemGrid: some View { ... }

// Good: extracted component struct
private struct <Feature>CardView: View { ... }

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
.animation(.spring(response: 0.45, dampingFraction: 0.8), value: items.map(\.id))
```

### Accessibility

- All interactive elements need `.accessibilityLabel` when the visual label is non-obvious
- `Button` labels must be descriptive: `"View \(item.name) details"`, not `"Tap"`
- `Image` with informational content needs `.accessibilityLabel`; decorative images use `.accessibilityHidden(true)`
- Minimum tap target: 44×44 pt — use `.frame(minWidth: 44, minHeight: 44)` for small controls

## Testing Standards

ViewModel unit tests follow the same framework choice as the rest of the project —
**Swift Testing** (`@Test`/`#expect`) or **XCTest** — as described in
`docs/domain-data-standards.md`. End-to-end UI flows use **XCUITest** regardless of the unit
framework chosen.

### UI Tests with XCUITest

UI tests live in `<AppName>UITests/`. They test real navigation flows against the running app.

```swift
final class <Feature>ListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test<Feature>List_displaysItems() {
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
    <Feature>CardView(item: MockDataFactory.make<Entity>Entity(), cacheManager: MockImageCacheManager())
        .padding()
}

#Preview("Empty State") {
    EmptyStateView(icon: "magnifyingglass", title: "No Results", subtitle: "Try again.")
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
- **ViewModel ownership**: the view that *creates* a ViewModel owns it (`@State` with `@Observable`, or `@StateObject` with `ObservableObject`); a ViewModel *passed in* is not owned (plain property, or `@ObservedObject`) — getting this wrong causes random re-initialization
- **Image loading**: the cached image component uses a two-level cache (memory + disk) — never bypass it by loading images manually in a view

## Related: Advanced & Optional Topics

See `docs/advanced-topics.md` for optional topics that also touch the Presentation layer when they
apply — splitting features into Swift packages (**SPM modularization**) and adopting the
**Swift 6 language mode / strict concurrency** for `@MainActor` ViewModels and `Sendable` state.
