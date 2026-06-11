## Why

The project already uses async/await, `@MainActor` ViewModels, and `Sendable` domain entities, but several Core and Presentation components still share mutable state across isolation boundaries without compile-time protection. `ImageCacheManager` mutates `NSCache` and disk from the main actor and unstructured background tasks concurrently; `AppGroupStore` is marked `Sendable` at the protocol level while the concrete type performs parallel `UserDefaults` and file I/O from detached tasks. With `SWIFT_STRICT_CONCURRENCY = targeted` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, these gaps are latent data-race risks that will surface more aggressively under Complete checking or Swift 6. Hardening now preserves current behaviour while aligning infrastructure with the project's concurrency standards.

## What Changes

- Convert `ImageCacheManager` to an `actor` (or equivalent isolation) so memory and disk cache access is serialized; update `ImageCacheManagerProtocol` and `CachedAsyncImageView` to use `async` cache APIs.
- Convert `AppGroupStore` to an `actor` so snapshot reads/writes and parallel image downloads no longer race on shared mutable storage; keep `AppGroupStoreProtocol` as the DI boundary with correct `Sendable` semantics.
- Replace `Task.detached` in `CharactersListViewModel.writeWidgetSnapshot()` with structured `Task { @concurrent in ... }` and ensure widget image downloads do not block the main actor.
- Move search debounce waiting off the main actor in `CharactersListViewModel.onSearchTextChanged()` while keeping UI state mutations on `@MainActor`.
- Update test doubles (`MockAppGroupStore`, any cache mocks) and affected unit tests for async actor APIs.
- Add targeted concurrency tests for cache isolation and `AppGroupStore` parallel download behaviour.

## Capabilities

### New Capabilities

- `thread-safe-image-cache`: Defines actor-isolated image caching requirements for memory and disk tiers, async protocol surface, and safe use from SwiftUI image loading.
- `thread-safe-app-group-store`: Defines actor-isolated widget snapshot and image download requirements, including parallel downloads via structured concurrency and correct `Sendable` protocol contracts.
- `viewmodel-structured-tasks`: Defines structured-concurrency patterns for ViewModel background work (debounce, widget snapshot side effects) without `Task.detached` unless explicitly justified.

### Modified Capabilities

<!-- No existing openspec/specs/ capability requirements change at the behavioural level.
     User-visible flows, navigation, and API responses remain the same. -->

## Impact

- **Core layer**: `ImageCacheManager`, `ImageCacheManagerProtocol`, `AppGroupStore`, `AppGroupStoreProtocol`, `DIContainer` wiring.
- **Presentation layer**: `CachedAsyncImageView`, `CharactersListViewModel` (debounce and widget snapshot tasks).
- **Tests**: `AppGroupStoreTests`, `CharactersListViewModelWidgetTests`, new cache concurrency tests; mock updates in `RickMortyChallengeTests/Mocks/`.
- **Widget extension**: `CharacterWidgetProvider` continues using WidgetKit completion APIs (unchanged API surface); reads go through the actor-isolated store.
- **No Domain or Data layer protocol changes** beyond test mock adjustments.
- **No breaking public API** for end users; **BREAKING** for internal test/production types that call synchronous cache or store methods synchronously.

## Non-goals

- Migrating the project to Swift 6 language mode or `SWIFT_STRICT_CONCURRENCY = complete`.
- Replacing `ObservableObject` / `@Published` with `@Observable`.
- Refactoring repository, use case, or networking layers (already async and largely stateless).
- Removing `@MainActor` from ViewModels or broadening `@Suite @MainActor` cleanup across all test files unless required by API changes.
- Converting WidgetKit `TimelineProvider` completion handlers to async (platform API constraint).
- Performance profiling or Instruments-based optimization beyond correctness fixes.

## Test Strategy

- **Unit tests (Swift Testing)**: Extend `AppGroupStoreTests` for actor/async APIs; add `ImageCacheManager` concurrency tests; update `CharactersListViewModelWidgetTests` and any cache-dependent tests; keep Domain/Data coverage ≥ 90%.
- **Simulator verification**: Smoke-test character list scrolling (pagination + cached images), pull-to-refresh, search debounce, and widget snapshot refresh after loading characters — confirm no UI regressions.
- **XCUITest**: Run existing `CharactersListUITests` and `NavigationUITests` — no new flows expected; confirm green after internal API changes.
- **Screenshot regression**: Re-run screenshot suite if `CachedAsyncImageView` timing changes affect baselines; update only if diffs are expected.

## Affected Clean Architecture Layers

- **Core** (primary): image cache and app-group storage infrastructure.
- **Presentation** (secondary): `CachedAsyncImageView`, `CharactersListViewModel` task patterns.
- **Tests** (supporting): mocks and concurrency-focused test coverage.
