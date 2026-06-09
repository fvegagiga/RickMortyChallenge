# Rick & Morty — iOS App

A production-quality iOS application that displays characters, locations, and episodes from the [Rick and Morty REST API](https://rickandmortyapi.com/documentation), with image persistence, a home screen widget, clean architecture, full testing, and a modern SwiftUI interface.

---

## Screenshots

| Characters | Detail | Locations | Episodes |
|:---:|:---:|:---:|:---:|
| Grid of character cards with status | Full-screen detail with hero image | Paginated location list | Season-coded episode list |

---

## Features

### Characters Tab

- **List** — 2-column `LazyVGrid` of character cards with avatar, name, status badge, and species
- **Search** — `.searchable` by name with 500ms debounce
- **Detail** — Hero image, status badge, species, status, gender, origin, location, type, and episode count
- **Pagination** — Infinite scroll via `loadMoreIfNeeded(currentItem:)` on the last item
- **Pull-to-refresh** — Resets and reloads page 1
- **States** — `ViewState`: loading, success, empty, error (with retry)
- **Widget sync** — On successful fetch, writes a shuffled 20-character snapshot to App Group for the home screen widget

### Locations Tab

- **List** — Plain `List` with type-specific SF Symbol icon, name, type, dimension, and resident count
- **Pagination** — Same `loadMoreIfNeeded` pattern as Characters
- **Pull-to-refresh** — Yes
- **States** — Loading, success, empty, error (with retry)
- No search or detail screen

### Episodes Tab

- **List** — Plain `List` with season-coded episode badge (e.g. `S01`), name, air date, and character count
- **Pagination** — Same `loadMoreIfNeeded` pattern
- **Pull-to-refresh** — Yes
- **States** — Loading, success, empty, error (with retry)
- No search or detail screen

### Shared UI

- `LoadingView`, `ErrorView` (retry action), `EmptyStateView`
- `StatusBadgeView` — Alive / Dead / Unknown with color-coded dot
- `CachedAsyncImageView` — Memory → disk → network image loading
- `View+Extensions` — `cardStyle()`, `shimmer()` placeholder effect

### Home Screen Widget (iOS 17+)

- **Sizes** — `.systemSmall`, `.systemMedium`
- **Display** — Character image, name, status indicator (colored dot), index counter (`1 / N`)
- **Navigation** — Interactive ← / → via `AppIntent` (`PreviousCharacterIntent`, `NextCharacterIntent`)
- **Data** — Reads character snapshot and images from App Group container written by the main app
- **Placeholder** — "Open the app to load characters" when App Group is empty

---

## Tech Stack

| Concern | Solution |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Architecture | MVVM + Clean Architecture |
| Concurrency | `async/await` (Combine used only for `ObservableObject` / `@Published`) |
| Image Persistence | FileManager + NSCache (two-level) |
| Networking | [Network SPM](https://github.com/fvegagiga/Network) v1.0.2 (`NetworkService`, `RetryingNetworkService`) |
| Widget | WidgetKit + App Intents |
| Data Sharing | App Group (`group.com.fvg0902iosdev.RickMortyChallenge.widget`) |
| Minimum Deployment | iOS 16.6 |
| Testing | XCTest (Unit + UI + Screenshot Regression) |
| CI | GitHub Actions (`.github/workflows/ios-tests.yml`) |
| DI | Manual constructor injection via `DIContainer` |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  MainTabView · Views · ViewModels · ViewState<T>        │
└──────────────────────┬──────────────────────────────────┘
                       │ depends on
┌──────────────────────▼──────────────────────────────────┐
│                      Domain Layer                        │
│  Entities · RepositoryProtocols · UseCases              │
└──────────────────────┬──────────────────────────────────┘
                       │ implemented by
┌──────────────────────▼──────────────────────────────────┐
│                       Data Layer                         │
│  RepositoryImpls · DTOs · Mappers · APIEndpoint         │
└─────────────────────────────────────────────────────────┘
                   ↑ shared by all
┌─────────────────────────────────────────────────────────┐
│                      Core / Common                       │
│  DIContainer · AppRouter · DesignSystem · Storage        │
└─────────────────────────────────────────────────────────┘
```

For a visual overview, open [`RickMortyArchitecture.drawio`](RickMortyArchitecture.drawio) in [draw.io](https://app.diagrams.net/) (or diagrams.net). The diagram shows the four Clean Architecture layers, external dependencies, and the widget extension at a glance.

### Layers Explained

**Domain** — Zero external dependencies. Defines `Entities` (pure data models), `RepositoryProtocols` (boundaries), and `UseCases` (one action = one class). This is the innermost ring.

**Data** — Implements the repository protocols. `DTOs` mirror the API JSON exactly; `Mappers` convert them to domain entities. `APIEndpoint` defines REST paths locally; HTTP transport comes from the Network SPM package (`NetworkServiceProtocol`, `RetryingNetworkService`).

**Presentation** — `ViewModels` are `@MainActor ObservableObject` classes that call use cases and expose `ViewState<T>`. Views are pure declarative SwiftUI with zero business logic.

**Core** — Infrastructure shared across layers: `DIContainer`, `AppRouter` (with `CharacterRoute`), `DesignSystem`, `ImageCacheManager`, and `AppGroupStore` for widget data sharing.

---

## Project Structure

```
RickMortyChallenge/
├── Core/
│   ├── DI/
│   │   └── DIContainer.swift          # Dependency graph + ViewModel factories
│   ├── Router/
│   │   └── AppRouter.swift            # NavigationPath + CharacterRoute enum
│   ├── DesignSystem/
│   │   ├── DSColors.swift             # Semantic color tokens
│   │   ├── DSTypography.swift         # Font scale
│   │   └── DSSpacing.swift            # Spacing & radius
│   ├── Storage/
│   │   ├── AppGroupStore.swift        # App Group read/write for widget
│   │   └── CharacterWidgetData.swift  # Shared widget model (app + extension)
│   ├── Extensions/
│   │   └── View+Extensions.swift      # cardStyle, shimmer
│   └── Utilities/
│       └── ImageCacheManager.swift    # NSCache + FileManager
│
├── Data/
│   ├── Network/
│   │   └── APIEndpoint.swift          # REST endpoint definitions
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
    ├── MainTabView.swift              # 3-tab root (Characters, Locations, Episodes)
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

CharacterWidgetExtension/              # WidgetKit extension (iOS 17+)
├── CharacterWidget.swift
├── CharacterWidgetView.swift
├── CharacterWidgetProvider.swift
├── NextCharacterIntent.swift
└── PreviousCharacterIntent.swift

RickMortyChallengeTests/
├── Mocks/
│   ├── MockDataFactory.swift
│   ├── MockCharacterRepository.swift
│   ├── MockLocationRepository.swift
│   ├── MockEpisodeRepository.swift
│   ├── MockNetworkService.swift
│   └── MockAppGroupStore.swift
├── UseCases/
│   ├── GetCharactersUseCaseTests.swift
│   ├── GetLocationsUseCaseTests.swift
│   └── GetEpisodesUseCaseTests.swift
├── ViewModels/
│   ├── CharactersListViewModelTests.swift
│   ├── CharactersListViewModelWidgetTests.swift
│   ├── CharacterDetailViewModelTests.swift
│   └── LocationsListViewModelTests.swift
├── Repositories/
│   └── CharacterRepositoryTests.swift
├── Storage/
│   └── AppGroupStoreTests.swift
└── Widget/
    └── CharacterNavigationIntentTests.swift

RickMortyChallengeUITests/
├── CharactersListUITests.swift
└── NavigationUITests.swift

RickMortyChallengeScreenshotTests/
├── ScreenshotRegressionTests.swift
└── snapshots/                         # 15 baseline PNGs
```

**External dependency:** [Network SPM](https://github.com/fvegagiga/Network) — provides `NetworkServiceProtocol`, `NetworkService`, `RetryingNetworkService`, `Endpoint`, `NetworkError`.

---

## Key Technical Decisions

### 1. Protocol-First Dependency Inversion
Every cross-layer dependency is expressed as a protocol, never as a concrete type:
- `NetworkServiceProtocol` (Network SPM) — only the Data layer talks to the network
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

### 8. App Group for Widget Data Sharing
`AppGroupStore` writes a JSON-encoded character snapshot and pre-downloaded images to the shared App Group container. The widget extension reads from the same container, enabling offline widget display without opening the app.

---

## Testing Strategy

### Unit Tests — Behaviour, Not Implementation

Tests verify **observable behaviour** (state changes, call counts, error propagation), not private implementation details. Mocks implement the same protocols as production code — no method swizzling, no reflection.

| Layer | What is tested |
|---|---|
| **Use Cases** | Delegates correctly to repository, propagates errors |
| **ViewModels** | State transitions (idle→loading→success/empty/failure), pagination, refresh, widget snapshot writes |
| **Repositories** | Maps DTOs to entities, sets `hasNextPage` correctly, propagates network errors |
| **Storage** | App Group snapshot write/read, index persistence, image URL resolution |
| **Widget** | Next/previous index math and wrap-around via App Intents |

**Known gaps (no tests yet):** `GetCharacterDetailUseCase`, `EpisodesListViewModel`, `LocationRepositoryImpl`, `EpisodeRepositoryImpl`, search debounce timing.

### UI Tests — Golden Path + Navigation

| Test | Validates |
|---|---|
| `testCharactersTab_isDefaultSelectedAndShowsTitle` | App launches with correct tab and nav title |
| `testTappingCharacterCard_navigatesToDetail` | NavigationStack routing is wired end-to-end |
| `testTabBar_containsAllThreeTabs` | All three tabs exist in the TabView |
| `testSwitchingTabs_showsCorrectNavigationTitle` | Each tab shows its own navigation stack |

### Screenshot Regression Tests

The project includes a dedicated test target: `RickMortyChallengeScreenshotTests`, backed by a **versioned local Swift package** at `Packages/SnapshotTestKit/`. The package provides snapshot assertion helpers and must remain tracked in git (see `.gitignore` exception for `Packages/SnapshotTestKit/`).

- Fixed simulator profile: `iPhone 16` (`OS 18.5` on CI; `18.4` or later locally)
- Fixed rendering environment: light mode, `en_US_POSIX`, medium content size, left-to-right layout
- Covered screen entry points:
  - Characters list (`content`, `loading`, `empty`, `error`)
  - Character detail (`content`, `loading`, `error`)
  - Locations list (`content`, `loading`, `empty`, `error`)
  - Episodes list (`content`, `loading`, `empty`, `error`)

Baselines are stored in `RickMortyChallengeScreenshotTests/snapshots/`.

To refresh baselines after intentional UI changes:

1. Temporarily set `RECORD_SNAPSHOTS` to `1` in the `RickMortyChallengeScreenshotTests` scheme.
2. Run `xcodebuild test -project "RickMortyChallenge.xcodeproj" -scheme "RickMortyChallengeScreenshotTests" -destination "platform=iOS Simulator,name=iPhone 16,OS=18.4"`
3. Set `RECORD_SNAPSHOTS` back to `0` in the scheme.
4. Run the same command again to verify the refreshed baselines.
5. Review updated PNG files in `RickMortyChallengeScreenshotTests/snapshots/`
6. Commit the baseline PNG updates together with the UI change

---

## CI/CD

GitHub Actions workflow (`.github/workflows/ios-tests.yml`) runs on every push to `main` and on pull requests:

- **Runner:** `macos-15`
- **Simulator:** iPhone 16, iOS 18.5 (GitHub Actions `macos-15` runner with Xcode 16.4)
- **Unit + UI tests:** `RickMortyChallenge` scheme
- **Screenshot regression:** `RickMortyChallengeScreenshotTests` scheme (depends on local `Packages/SnapshotTestKit`)

**Local packages:** The `Packages/` directory is gitignored by default. Any local Swift package referenced by the Xcode project must be explicitly allow-listed in `.gitignore` (currently `Packages/SnapshotTestKit/`).

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

1. Open `RickMortyChallenge.xcodeproj` in Xcode
2. Select a simulator (iPhone 16 or later recommended)
3. Press `⌘R` to run
4. Press `⌘U` to run all unit tests
5. For UI tests, select the `RickMortyChallengeUITests` scheme and press `⌘U`
6. For screenshot tests, select the `RickMortyChallengeScreenshotTests` scheme and press `⌘U`

---

## Home Screen Widget

The app includes a **Character Navigation Widget** (iOS 17+) that displays Rick & Morty characters directly on the home screen with ← → navigation arrows.

### Adding the Widget

1. Long-press the home screen and tap the **+** button
2. Search for "Rick & Morty Character"
3. Choose **Small** or **Medium** size
4. Tap **Add Widget**

### How It Works

- The widget is populated automatically the first time you open the app and load the Characters tab
- Each app launch refreshes the widget with a new random selection of 20 characters
- Tap ← / → to cycle through characters without opening the app
- Character images are pre-downloaded to the App Group container for fast widget rendering

### Xcode Targets (for contributors)

The widget extension is already configured in the Xcode project:

| Target | Bundle ID |
|---|---|
| `RickMortyChallenge` | `com.fvg0902iosdev.RickMortyChallenge` |
| `CharacterWidgetExtensionExtension` | `com.fvg0902iosdev.RickMortyChallenge.CharacterWidgetExtension` |

Both targets share App Group `group.com.fvg0902iosdev.RickMortyChallenge.widget`. Source files live in `CharacterWidgetExtension/` and `RickMortyChallenge/Core/Storage/`.

---

## Author

Fernando Vega — Senior iOS Developer
