## Context

The `swift-concurrency-improvements` change (archived 2026-06-11) promoted `AppGroupStore` and `ImageCacheManager` to actors, refactored ViewModel side effects to structured concurrency, and synced main specs. Adversarial review rated the work **PASS WITH GAPS**:

- `AppGroupStoreTests` cover snapshot/index behaviour but not `downloadImages(for:)`.
- `CharactersListViewModelTests` lack debounce cancellation coverage despite the spec requiring it.
- `thread-safe-app-group-store` overclaims full `UserDefaults` isolation; widget reads remain `nonisolated` by design.
- `character-data-sharing` still describes synchronous `writeSnapshot`.
- Minor hygiene: `clearMemoryCacheForTesting()` is public in production; parallel cache test only checks non-nil; widget tests omit `downloadImagesCallCount`.

**Documented invariant:** WidgetKit requires synchronous reads (`CharacterWidgetProvider`, navigation intents). Full actor serialization of every `UserDefaults` access is out of scope. Cross-key atomicity between `widget.characters` and `widget.currentIndex` is best-effort via write ordering in `writeSnapshot`, not transactional.

## Goals / Non-Goals

**Goals:**

- Close all adversarial-review gaps with TDD (failing tests first).
- Align OpenSpec requirements with actual isolation boundaries.
- Restrict test-only APIs from production builds.
- Preserve all user-visible behaviour; no Domain/Data logic changes.

**Non-Goals:**

- Swift 6 migration or enabling strict concurrency.
- Refactoring `AppGroupStore` to async-only reads (breaks WidgetKit).
- New features, navigation changes, or REST API changes.
- xcscheme / commit workflow (handled manually).

## Decisions

### 1. Spec alignment before code (baby step 1)

Update delta specs and add the `AppGroupStore` invariant comment before writing new tests. This prevents re-implementing against stale requirements.

**Alternative considered:** Code-first then spec sync — rejected because review gaps are primarily spec/test coverage issues.

### 2. `AppGroupStore.downloadImages` test strategy

Use the existing `AppGroupStore(defaults:urlSession:)` initializer:

- **Skip-existing:** Pre-create `{id}.jpg` at `sut.imageURL(for:)` when the App Group container is available; call `downloadImages` and assert the stub session received zero requests (via a test `URLProtocol` or session delegate counter).
- **Download-when-missing:** Register a `URLProtocol` stub returning fixed JPEG bytes; assert file exists at destination after `await sut.downloadImages(for:)`.
- **Parallel completion:** Invoke `downloadImages` with multiple characters inside `withTaskGroup`; assert all complete without crash and files exist.

When `imageContainerURL()` returns `nil` (no App Group in test host), tests SHALL use `#require` or early guard with a documented skip — prefer running on the simulator test host where entitlements resolve the container.

**Alternative considered:** Inject `imageContainerURL` — rejected (out of scope behaviour change).

### 3. Debounce tests in `CharactersListViewModelTests`

- **Cancellation:** Set `searchText`, call `onSearchTextChanged()`, immediately call again before 500 ms; assert `fetchCharactersCallCount` unchanged after a short yield (first task cancelled).
- **Success:** Single debounce call, `await Task.sleep(nanoseconds: 600_000_000)`, assert fetch triggered and `viewState` updated.

Use the existing `MockCharacterRepository.fetchCharactersCallCount` — no new test doubles required.

**Alternative considered:** Inject a clock — rejected as over-engineering for a fixed 500 ms debounce.

### 4. Widget test `downloadImagesCallCount`

After `await sut.loadInitial()`, yield briefly (`await Task.yield()` in a short loop or `Task.sleep` ~100 ms) to allow the fire-and-forget `@concurrent` download task to run, then assert `mockStore.downloadImagesCallCount == 1`.

### 5. Strengthen parallel cache test

In `parallelStoreAndRead`, track expected colour per URL index; after the task group, assert each `await sut.image(for: url)` returns an image whose dominant pixel colour matches the stored colour (reuse existing `makeImage(color:)` helper with distinct colours per index).

Aligns with `thread-safe-image-cache` scenario: "final cached value for each URL SHALL match the last stored image data."

### 6. `clearMemoryCacheForTesting()` visibility

Wrap in `#if DEBUG` on `ImageCacheManager`. Tests compile against `@testable import` in Debug configuration — consistent with Xcode test runs.

**Alternative considered:** Separate test subclass — rejected; `#if DEBUG` is the project-consistent minimal change.

### 7. Simulator and XCUITest scope

This change adds tests and minor visibility/docs updates only. No user-facing flow changes.

- **Simulator (Step N+2):** Skip with rationale — test-only and `#if DEBUG` visibility changes; no Presentation behaviour change.
- **XCUITest (Step N+3):** Run as regression guard only (existing suite).

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| App Group container unavailable in unit test host | Document entitlement requirement; use `#require` guard; verify on simulator CI |
| Fire-and-forget download task timing in widget test | Brief yield/retry loop; assert with reasonable timeout |
| `#if DEBUG` hides helper from Release test builds | Project tests run Debug; document in design |
| Spec MODIFIED blocks must be complete at archive | Copy full requirement blocks from main specs before editing |

## Migration Plan

1. Create branch `feature/swift-concurrency-follow-ups`.
2. Apply spec deltas and code comment (no runtime change).
3. TDD: failing tests → green implementation (mostly test-only; `#if DEBUG` wrap).
4. Run targeted then full unit suite; coverage check.
5. XCUITest regression.
6. Archive via `/opsx:archive` to sync main specs.

No rollback beyond reverting the branch — no production behaviour changes.

## Open Questions

_None — adversarial review and task definition provide sufficient scope._
