# Rick & Morty — iOS Technical Challenge

A production-quality iOS application built for a **Senior iOS Developer** technical interview. Displays characters, locations, and episodes from the [Rick and Morty REST API](https://rickandmortyapi.com/documentation), with image persistence, clean architecture, full testing, and a modern SwiftUI interface.

---

## Screenshots

| Characters | Detail | Locations | Episodes |
|:---:|:---:|:---:|:---:|
| Grid of character cards with status | Full-screen detail with hero image | Paginated location list | Season-coded episode list |

---

## Tech Stack

| Concern | Solution |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Architecture | MVVM + Clean Architecture |
| Concurrency | `async/await` (no Combine) |
| Image Persistence | FileManager + NSCache (two-level) |
| Networking | `URLSession` with protocol abstraction |
| Minimum Deployment | iOS 16.0 |
| Testing | XCTest (Unit + UI) |
| DI | Manual constructor injection via `DIContainer` |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  Views  ←→  ViewModels  ←  UseCaseProtocols             │
└──────────────────────┬──────────────────────────────────┘
                       │ depends on
┌──────────────────────▼──────────────────────────────────┐
│                      Domain Layer                        │
│  Entities · RepositoryProtocols · UseCases              │
└──────────────────────┬──────────────────────────────────┘
                       │ implemented by
┌──────────────────────▼──────────────────────────────────┐
│                       Data Layer                         │
│  RepositoryImpls · DTOs · Mappers · NetworkService      │
└─────────────────────────────────────────────────────────┘
                   ↑ shared by all
┌─────────────────────────────────────────────────────────┐
│                      Core / Common                       │
│  DIContainer · AppRouter · DesignSystem · Utilities      │
└─────────────────────────────────────────────────────────┘
```

### Layers Explained

**Domain** — Zero external dependencies. Defines `Entities` (pure data models), `RepositoryProtocols` (boundaries), and `UseCases` (one action = one class). This is the innermost ring.

**Data** — Implements the repository protocols. `DTOs` mirror the API JSON exactly; `Mappers` convert them to domain entities. This is the only layer that knows about the network.

**Presentation** — `ViewModels` are `@MainActor ObservableObject` classes that call use cases and expose `ViewState<T>`. Views are pure declarative SwiftUI with zero business logic.

**Core** — Infrastructure shared across layers: `DIContainer`, `AppRouter`, `DesignSystem`, `ImageCacheManager`.

---

## Project Structure

```
RickMortyPersistImage/
├── Core/
│   ├── DI/
│   │   └── DIContainer.swift          # Dependency graph
│   ├── Router/
│   │   ├── AppRoute.swift             # Typed navigation enums
│   │   └── AppRouter.swift            # NavigationPath per tab
│   ├── DesignSystem/
│   │   ├── DSColors.swift             # Semantic color tokens
│   │   ├── DSTypography.swift         # Font scale
│   │   └── DSSpacing.swift            # Spacing & radius
│   ├── Extensions/
│   │   └── View+Extensions.swift      # cardStyle, shimmer
│   └── Utilities/
│       └── ImageCacheManager.swift    # NSCache + FileManager
│
├── Data/
│   ├── Network/
│   │   ├── NetworkServiceProtocol.swift
│   │   ├── NetworkService.swift
│   │   ├── APIEndpoint.swift
│   │   └── NetworkError.swift
│   ├── DTOs/
│   │   ├── PaginatedResponseDTO.swift
│   │   ├── CharacterDTO.swift
│   │   ├── LocationDTO.swift
│   │   └── EpisodeDTO.swift
│   ├── Mappers/
│   │   ├── CharacterMapper.swift
│   │   ├── LocationMapper.swift
│   │   └── EpisodeMapper.swift
│   └── Repositories/
│       ├── CharacterRepositoryImpl.swift
│       ├── LocationRepositoryImpl.swift
│       └── EpisodeRepositoryImpl.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── CharacterEntity.swift
│   │   ├── LocationEntity.swift
│   │   └── EpisodeEntity.swift
│   ├── Repositories/
│   │   ├── PagedResult.swift
│   │   ├── CharacterRepositoryProtocol.swift
│   │   ├── LocationRepositoryProtocol.swift
│   │   └── EpisodeRepositoryProtocol.swift
│   └── UseCases/
│       ├── GetCharactersUseCase.swift
│       ├── GetCharacterDetailUseCase.swift
│       ├── GetLocationsUseCase.swift
│       └── GetEpisodesUseCase.swift
│
└── Presentation/
    ├── MainTabView.swift
    ├── Components/
    │   ├── ViewState.swift            # idle/loading/success/empty/failure
    │   ├── LoadingView.swift
    │   ├── ErrorView.swift
    │   ├── EmptyStateView.swift
    │   ├── StatusBadgeView.swift
    │   └── CachedAsyncImageView.swift
    ├── Characters/
    │   ├── Views/
    │   │   ├── CharactersListView.swift
    │   │   ├── CharacterDetailView.swift
    │   │   └── CharacterCardView.swift
    │   └── ViewModels/
    │       ├── CharactersListViewModel.swift
    │       └── CharacterDetailViewModel.swift
    ├── Locations/
    │   ├── Views/
    │   │   ├── LocationsListView.swift
    │   │   └── LocationRowView.swift
    │   └── ViewModels/
    │       └── LocationsListViewModel.swift
    └── Episodes/
        ├── Views/
        │   ├── EpisodesListView.swift
        │   └── EpisodeRowView.swift
        └── ViewModels/
            └── EpisodesListViewModel.swift

RickMortyPersistImageTests/
├── Mocks/
│   ├── MockDataFactory.swift
│   ├── MockCharacterRepository.swift
│   ├── MockLocationRepository.swift
│   ├── MockEpisodeRepository.swift
│   └── MockNetworkService.swift
├── UseCases/
│   ├── GetCharactersUseCaseTests.swift
│   ├── GetLocationsUseCaseTests.swift
│   └── GetEpisodesUseCaseTests.swift
├── ViewModels/
│   ├── CharactersListViewModelTests.swift
│   ├── CharacterDetailViewModelTests.swift
│   └── LocationsListViewModelTests.swift
└── Repositories/
    └── CharacterRepositoryTests.swift

RickMortyPersistImageUITests/
├── CharactersListUITests.swift
└── NavigationUITests.swift
```

---

## Key Technical Decisions

### 1. Protocol-First Dependency Inversion
Every cross-layer dependency is expressed as a protocol, never as a concrete type:
- `NetworkServiceProtocol` — the Data layer never touches `URLSession` directly from other layers
- `CharacterRepositoryProtocol` — Domain defines the interface; Data implements it
- `GetCharactersUseCaseProtocol` — ViewModels depend on the protocol, enabling fast mock injection in tests

**Why**: This is the **D** in SOLID (Dependency Inversion). Swapping `NetworkService` for a mock requires zero changes to ViewModels or UseCases.

### 2. ViewState<T> — Explicit State Machine
All asynchronous screens use `ViewState<T>` with five cases: `.idle`, `.loading`, `.success(T)`, `.empty`, `.failure(Error)`. The ViewModel can only be in one state at a time, which eliminates the impossible combination of `isLoading && hasError`.

**Why**: Implicit boolean flags (`isLoading`, `hasData`, `error`) lead to incoherent states. An enum makes illegal states unrepresentable.

### 3. Two-Level Image Cache
`ImageCacheManager` stores images in:
1. **NSCache** (in-memory) — O(1) lookup, automatically evicted under memory pressure
2. **FileManager** (disk) — survives app restarts

Cache writes to disk happen in a `Task(priority: .background)` to avoid blocking the main actor.

**Why**: `AsyncImage` provides no persistence. Repeated scrolling would re-download the same avatars on every launch, degrading UX and wasting bandwidth.

### 4. Pagination via `loadMoreIfNeeded`
ViewModels expose `loadMoreIfNeeded(currentItem:)`. The view calls this inside `.task {}` on each list item. The ViewModel only fetches if `currentItem.id == allItems.last?.id`, making it O(1) and free of index arithmetic.

**Why**: Traditional `onAppear` + index comparison is fragile. This approach is robust to async reordering and avoids the "load on second-to-last" off-by-one bug.

### 5. DIContainer as ViewModel Factory
`DIContainer` is passed as `@EnvironmentObject` and exposes `make*ViewModel()` factory methods. Detail ViewModels are created on demand inside `navigationDestination`, ensuring each screen owns its own state and lifecycle.

**Why**: A single shared ViewModel per screen would reset when navigating back. Factories give each navigation destination a fresh, isolated ViewModel.

### 6. Search Debounce
`CharactersListViewModel` cancels and restarts a `Task` with 500ms delay on every keystroke. This prevents hammering the API on every character typed.

**Why**: Without debounce, a 10-character search fires 10 network requests and the responses arrive out of order, corrupting the displayed list.

### 7. SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
The project has this build flag enabled, meaning all types are implicitly `@MainActor`. ViewModels explicitly annotate `@MainActor` for clarity and documentation. Async URLSession calls suspend the actor without blocking the main thread.

---

## Testing Strategy

### Unit Tests — Behaviour, Not Implementation

Tests verify **observable behaviour** (state changes, call counts, error propagation), not private implementation details. Mocks implement the same protocols as production code — no method swizzling, no reflection.

| Layer | What is tested |
|---|---|
| **Use Cases** | Delegates correctly to repository, propagates errors |
| **ViewModels** | State transitions (idle→loading→success/empty/failure), pagination, refresh, debounce idempotency |
| **Repositories** | Maps DTOs to entities, sets `hasNextPage` correctly, propagates network errors |

### UI Tests — Golden Path + Navigation

| Test | Validates |
|---|---|
| `testCharactersTab_isDefaultSelectedAndShowsTitle` | App launches with correct tab and nav title |
| `testTappingCharacterCard_navigatesToDetail` | NavigationStack routing is wired end-to-end |
| `testTabBar_containsAllThreeTabs` | All three tabs exist in the TabView |
| `testSwitchingTabs_showsCorrectNavigationTitle` | Each tab shows its own navigation stack |

---

## Scalability Examples

| Feature | How to add |
|---|---|
| **Filter by status/gender** | Add parameters to `GetCharactersUseCase`, `CharacterRepositoryProtocol`, `APIEndpoint.characters` |
| **Offline mode / caching** | Add a `LocalCharacterDataSource` protocol and decorate `CharacterRepositoryImpl` with a `CachingCharacterRepository` |
| **SwiftData persistence** | Replace `CharacterRepositoryImpl` with a SwiftData-backed implementation — Domain and Presentation are unchanged |
| **New entity (e.g. Comics)** | Follow the pattern: Entity → Protocol → Impl → UseCase → ViewModel → View — each in its own folder |
| **Deep linking** | Extend `AppRouter` with `open(url:)` that maps URL paths to navigation routes |
| **Multiple environments (dev/staging/prod)** | Inject `APIEndpoint.baseURL` through `DIContainer` init parameter |

---

## Running the Project

1. Open `RickMortyPersistImage.xcodeproj` in Xcode
2. Select a simulator (iPhone 16 or later recommended)
3. Press `⌘R` to run
4. Press `⌘U` to run all unit tests
5. For UI tests, select the `RickMortyPersistImageUITests` scheme and press `⌘U`

No third-party dependencies. No SPM packages required.

---

## Author

Fernando Vega — Senior iOS Developer  
