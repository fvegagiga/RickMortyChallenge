## Why

The `swift-concurrency-improvements` change introduced actor-isolated `AppGroupStore` and `ImageCacheManager` plus structured ViewModel tasks, but adversarial review (**PASS WITH GAPS**) found missing test coverage, overstated isolation claims in specs, and minor production/test hygiene gaps. This follow-up closes those gaps so the branch meets its own OpenSpec requirements and is safe to merge.

## What Changes

- Add Swift Testing coverage for `AppGroupStore.downloadImages(for:)` (skip existing file, download when missing, parallel completion).
- Add debounce cancellation and successful debounce tests in `CharactersListViewModelTests`.
- Assert `downloadImagesCallCount == 1` in `CharactersListViewModelWidgetTests` after successful `loadInitial()`.
- Strengthen `ImageCacheManagerTests.parallelStoreAndRead` to assert per-URL image correctness, not merely non-nil.
- Restrict `ImageCacheManager.clearMemoryCacheForTesting()` to debug/test-only visibility.
- Document the two-key `UserDefaults` invariant and `nonisolated` read design in `AppGroupStore.swift`.
- Revise `thread-safe-app-group-store` isolation scenario to match the pragmatic `nonisolated` `UserDefaults` design.
- Sync `character-data-sharing` with the async `writeSnapshot` API and cross-link concurrency specs.
- Clarify parallel cache test expectations in `thread-safe-image-cache` if assertion changes.

## Non-goals

- Swift 6 migration or `SWIFT_STRICT_CONCURRENCY = complete`.
- Refactoring `AppGroupStore` to fully actor-serialize all `UserDefaults` access (would break WidgetKit synchronous reads).
- Changing widget behaviour, navigation, or REST API endpoints.
- Reverting xcscheme noise or git commit workflow (handled manually).

## Capabilities

### New Capabilities

_None — this change closes gaps in existing capabilities; no new capability specs are introduced._

### Modified Capabilities

- `thread-safe-app-group-store`: Revise isolation scenario to reflect `nonisolated` `UserDefaults` reads; add requirement for `downloadImages` test coverage.
- `thread-safe-image-cache`: Clarify parallel test correctness expectation; add requirement that test-only cache helpers are not production-visible.
- `viewmodel-structured-tasks`: Add requirement for debounce cancellation tests and `downloadImagesCallCount` assertion in widget ViewModel tests.
- `character-data-sharing`: Reference async `writeSnapshot` and cross-link `thread-safe-app-group-store` for concurrency details.

## Impact

**Layers:** Core (`AppGroupStore`, `ImageCacheManager`), Presentation tests (`CharactersListViewModelTests`, `CharactersListViewModelWidgetTests`), OpenSpec specs.

**APIs (visibility only):** `ImageCacheManager.clearMemoryCacheForTesting()` — restricted to `#if DEBUG` or equivalent test-only pattern. No behavioural changes to `AppGroupStoreProtocol`, `ImageCacheManagerProtocol`, or ViewModel public APIs.

**Test strategy:**
- TDD with Swift Testing — write failing tests first for each new scenario.
- Targeted `xcodebuild test` on `AppGroupStoreTests`, `CharactersListViewModelTests`, `CharactersListViewModelWidgetTests`, `ImageCacheManagerTests`.
- Full `RickMortyChallengeTests` suite; Domain/Data coverage ≥ 90% via `scripts/check-domain-data-coverage.py`.
- XCUITest regression (no new UI flows); optional simulator smoke for search debounce after test-only API changes.
