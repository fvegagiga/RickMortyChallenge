## Context

The main app fetches characters from the Rick & Morty API and displays them in a paginated grid. The widget extension is a separate process that cannot make network calls at render time and cannot import the main app module directly. Data must flow from the app to the widget via a shared App Group container, and user interaction (navigation arrows) must be handled via App Intents (iOS 17+).

Current state: no widget target exists. The app has a `DIContainer` for DI, `ImageCacheManager` for disk-based image caching (in the app sandbox), and `CharacterEntity` in the Domain layer.

## Goals / Non-Goals

**Goals:**
- Add a home screen widget (WidgetKit) that shows a character's image and name
- Support previous/next navigation via interactive App Intent buttons
- Pre-populate widget data from the main app's successful character load
- Support `.systemSmall` and `.systemMedium` families
- Keep the widget extension decoupled from the main app module

**Non-Goals:**
- Network calls from within the widget extension
- User-configurable character selection (IntentConfiguration)
- Episodes or Locations in the widget
- iOS < 17.0 support (App Intent interactive buttons require iOS 17+)
- Automatic background refresh of character data without opening the app

## Decisions

### Decision 1 — Interactive navigation via App Intents

**Chosen**: `AppIntent` conforming structs (`PreviousCharacterIntent`, `NextCharacterIntent`) invoked by `Button` views inside the widget. Each intent reads the current index from shared storage, increments/decrements with wrap-around, writes it back, and calls `WidgetCenter.shared.reloadAllTimelines()`.

**Alternatives considered**:
- *Multiple timeline entries auto-advancing*: no user control — rejected.
- *Deep link URL opening the app*: degrades UX (leaves widget, opens app) — rejected for navigation.

**Rationale**: App Intents are the only first-party mechanism for interactive widget buttons on iOS 17+. They run in the widget extension process itself, keeping the interaction fast and self-contained.

---

### Decision 2 — Shared data via App Group + UserDefaults (JSON)

**Chosen**: An App Group (`group.<bundle-id>.widget`) with `UserDefaults(suiteName:)` storing two keys:
- `widget.characters` — JSON-encoded `[CharacterWidgetData]` (id, name, imageFileName)
- `widget.currentIndex` — `Int`

**Alternatives considered**:
- *Shared FileManager JSON file*: equivalent complexity, no advantage — skipped.
- *CoreData with shared container*: overkill for a small array of lightweight structs — rejected.
- *App Group UserDefaults with raw image Data*: images can exceed UserDefaults size limits — rejected.

**Rationale**: UserDefaults with JSON-encoded lightweight structs is the simplest, safest approach. Images are stored separately as files (see Decision 3).

---

### Decision 3 — Images stored as files in shared App Group container

**Chosen**: When the main app loads characters, it downloads the image for each character in the snapshot and saves it to the shared App Group `FileManager` container as `<characterId>.jpg`. The widget reads images from this directory using `UIImage(contentsOfFile:)` — synchronous, no async needed.

**Alternatives considered**:
- *`AsyncImage` in widget*: unreliable in WidgetKit and requires network at render time — rejected.
- *Base64 image data in UserDefaults*: exceeds safe UserDefaults size limits for multiple images — rejected.
- *Reuse existing `ImageCacheManager`*: it writes to the app's sandbox, not accessible by the widget extension — not usable as-is.

**Rationale**: Storing pre-downloaded images in the shared App Group directory is the standard WidgetKit pattern for image-rich widgets. It avoids network calls at render time and reuses the URL already present in `CharacterEntity`.

---

### Decision 4 — Shared model via a plain Swift file added to both targets

**Chosen**: A single file `CharacterWidgetData.swift` (a `Codable` struct with `id`, `name`, `imageFileName`) added to both the main app target and the widget extension target via Xcode target membership.

**Alternatives considered**:
- *Local Swift Package (WidgetShared)*: cleaner long-term but adds setup overhead for a single struct — deferred.
- *Copy-paste separate structs in each target*: violates DRY and risks drift — rejected.

**Rationale**: The shared model is tiny and stable. A single file with dual target membership is the fastest path; it can be extracted to a local package later if the shared surface grows.

---

### Decision 5 — Snapshot size and randomization: 20 random characters

The App Group stores a snapshot of 20 characters randomly sampled from the currently loaded pool (`allCharacters.shuffled().prefix(20)`). This ensures the widget shows a different set each time the user opens the app or refreshes, avoiding repetition. As the user paginates through more characters, the pool grows and the variety increases. The main app writes this snapshot after each successful `CharactersListViewModel.loadInitial()` or `refresh()`.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| App Group entitlement misconfiguration causes widget to always show empty state | Write an `AppGroupStore` unit test that verifies round-trip encoding/decoding before wiring to ViewModel |
| Image download on main app side slows down character list load | Download widget images in a background `Task` detached from the main load path; do not block `ViewState.success` |
| UserDefaults write fails silently | Log errors from `AppGroupStore` write operations; widget shows placeholder gracefully |
| `WidgetCenter.reloadAllTimelines()` called too frequently degrades battery | Only call reload after successful App Intent navigation, not on every app launch |
| Character data in App Group becomes stale if user hasn't opened the app in a long time | Widget shows whatever data is cached; a "last updated" timestamp can be added in a future iteration |

## Migration Plan

1. Add App Group capability to main app target and widget extension target in Xcode
2. Add `CharacterWidgetExtension` target to the Xcode project
3. Add `CharacterWidgetData.swift` to both targets
4. Implement `AppGroupStore` in Core layer
5. Wire `AppGroupStore.writeSnapshot()` call into `CharactersListViewModel` after successful load
6. Implement widget extension (`Provider`, `Entry`, `View`, `AppIntents`)
7. Test on simulator: add widget to home screen, verify navigation

No rollback needed — this is an additive change. Removing the widget later requires only removing the extension target and App Group capability.

## Open Questions

- Should the widget snapshot be refreshed in the background (via `BGAppRefreshTask`) in a future iteration, or only on app open? → Deferred to future scope.
- Should `.systemLarge` family be supported with more character info (status, species)? → Future scope, acknowledged in Non-Goals.
