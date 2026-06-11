## Context

RickMortyChallenge uses Swift 5.0 with `SWIFT_STRICT_CONCURRENCY = targeted`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, and `SWIFT_APPROACHABLE_CONCURRENCY = YES` on the main app target. Presentation ViewModels are already `@MainActor`; domain entities and `PagedResult` conform to `Sendable`. Networking and repositories are async-first.

Two Core components break isolation discipline:

1. **`ImageCacheManager`** — a final class with synchronous methods mutating `NSCache` and `FileManager`. `CachedAsyncImageView` reads/writes from SwiftUI `.task` (main actor), while `store()` launches an unstructured `Task(priority: .background)` that also touches cache state paths. This is a classic shared-mutable-state race.

2. **`AppGroupStore`** — `AppGroupStoreProtocol` is marked `Sendable`, but the concrete class holds `UserDefaults` and performs parallel downloads via `withTaskGroup`. `CharactersListViewModel` calls `Task.detached` to invoke `downloadImages`, bypassing structured inheritance and masking isolation issues.

The project profile explicitly defers Swift 6 / Complete concurrency migration; this change hardens the worst offenders while staying on Swift 5 targeted checking.

## Goals / Non-Goals

**Goals:**

- Eliminate data-race risk in image caching and widget app-group storage using Swift-native isolation (`actor`).
- Align ViewModel side-effect tasks with structured concurrency (`Task { @concurrent in }`, main-actor hops only for UI mutation).
- Preserve all user-visible behaviour (cache tiers, widget snapshot rules, search debounce timing, pagination).
- Maintain ≥ 90% Domain/Data test coverage and keep CI green.

**Non-Goals:**

- Swift 6 language mode or Complete strict concurrency.
- `@Observable` migration, repository redesign, or WidgetKit async timeline APIs.
- Broader test-suite `@MainActor` cleanup unrelated to changed APIs.

## Decisions

### 1. Use `actor` for `ImageCacheManager` (not `NSLock` / `@unchecked Sendable`)

**Choice:** Promote `ImageCacheManager` to `actor ImageCacheManager` and make protocol methods `async`.

**Rationale:** Matches `docs/advanced-topics.md` guidance and the swift-concurrency skill — protect shared mutable cache with an actor. Compiles cleanly under targeted checking without escape hatches.

**Alternatives considered:**

- **`@unchecked Sendable` + lock** — rejected; harder to audit and contradicts project standards.
- **MainActor isolation** — rejected; disk I/O and JPEG encoding should not run on the main actor.

**Call-site impact:** `CachedAsyncImageView.loadImage()` already async; add `await` to cache calls. `DIContainer` holds a single shared actor instance (actors are reference types; sharing is idiomatic).

### 2. Use `actor` for `AppGroupStore`

**Choice:** Promote `AppGroupStore` to `actor AppGroupStore`. Make mutating/read APIs that touch isolated state `async` (e.g., `writeSnapshot`, `downloadImages`, index accessors as needed).

**Rationale:** Serializes `UserDefaults` and file container access; parallel downloads remain inside the actor via `withTaskGroup` calling `nonisolated` network fetches or isolated helper methods that do not mutate shared state concurrently.

**Widget provider note:** `CharacterWidgetProvider.getSnapshot` / `getTimeline` use synchronous WidgetKit completions. Options:

- **Preferred:** expose `nonisolated` read-only snapshot helpers that only read immutable encoded data synchronously *if* proven safe, OR use a lightweight synchronous facade backed by atomically written `UserDefaults` data.
- **Fallback:** use `MainActor.assumeIsolated` — rejected without proof.
- **Pragmatic approach:** keep synchronous read methods as `nonisolated` on the actor only for decoding `UserDefaults` blobs where writes always go through `await writeSnapshot` on the actor — document that widget reads may see slightly stale data (already acceptable for widgets). Writes and downloads always `await` actor methods.

**Protocol shape:**

```swift
protocol AppGroupStoreProtocol: Sendable {
    func writeSnapshot(_ characters: [CharacterWidgetData]) async
    func downloadImages(for characters: [CharacterWidgetData]) async
    nonisolated func currentCharacter() -> CharacterWidgetData?  // if safe read path
    // ... or async reads if nonisolated reads are not viable
}
```

Implementation will pick the minimal surface that satisfies WidgetKit sync reads **and** strict concurrency — likely `nonisolated` reads from `UserDefaults` with writes isolated on the actor (UserDefaults is thread-safe for atomic plist operations; actor serializes write+index updates).

### 3. Replace `Task.detached` with `Task { @concurrent in }`

**Choice:** In `CharactersListViewModel.writeWidgetSnapshot()`:

```swift
Task { @concurrent in
    await store.downloadImages(for: snapshot)
}
```

**Rationale:** Skill guidance — detached tasks only with documented reason; here structured concurrent entry suffices because work is fire-and-forget background download with no need to escape task hierarchy.

### 4. Debounce sleep off main actor

**Choice:** Refactor `onSearchTextChanged()` to:

```swift
searchDebounceTask = Task { @concurrent in
    try? await Task.sleep(nanoseconds: 500_000_000)
    guard !Task.isCancelled else { return }
    await performSearch()
}
```

Because `performSearch()` is `@MainActor`, the final call hops to main actor automatically.

**Rationale:** Avoid holding main actor during 500 ms sleep; preserves debounce semantics.

### 5. Test doubles as actors or `@MainActor` classes

**Choice:** Update `MockAppGroupStore` to match protocol (actor mock or `@MainActor final class` with async methods). Prefer a simple `@MainActor final class` mock if tests are already `@MainActor` — avoids actor reentrancy complexity in tests.

**Rationale:** Tests run on main actor today; mock does not need cross-thread sharing.

### 6. Add `ImageCacheManagerTests`

**Choice:** New Swift Testing suite under `RickMortyChallengeTests` exercising parallel store/read via `withTaskGroup`.

**Rationale:** Spec requirement; cache had no dedicated tests despite being concurrency-sensitive.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Async cache API increases `await` points in SwiftUI `.task` | `.task` already async; minimal UX impact; verify image loading in simulator |
| Widget sync reads vs actor isolation | Use `nonisolated` read helpers backed by thread-safe `UserDefaults` reads; document invariant that writes go through actor |
| Mock/protocol churn breaks many tests | Update mocks in same PR; run full unit suite |
| Actor reentrancy during `downloadImages` | Keep network I/O in child tasks; mutate actor state only at await boundaries |
| Screenshot timing shifts | Re-run screenshot tests; update baselines only if legitimate visual delta |

## Migration Plan

1. **Phase A — Image cache:** Change protocol → actor implementation → `CachedAsyncImageView` → new tests → build.
2. **Phase B — App group store:** Actor + protocol async writes/downloads → update `MockAppGroupStore` → fix `AppGroupStoreTests` and widget tests → widget provider read path.
3. **Phase C — ViewModel tasks:** Debounce + remove `Task.detached` → update ViewModel tests.
4. **Verification:** Full `xcodebuild test`, simulator smoke, existing XCUITest, screenshot suite if needed.
5. **Rollback:** Revert branch; no schema or API migration required.

## Open Questions

- **Widget sync reads:** Confirm during implementation whether all widget read methods can remain `nonisolated` with `UserDefaults` thread safety, or whether iOS 17 WidgetKit offers async timeline APIs worth adopting later (out of scope now).
- **`writeSnapshot` async vs sync:** If widget/provider needs synchronous write from extension in future, revisit; current app-only writer is `@MainActor` ViewModel.
