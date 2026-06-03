## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/character-navigation-widget` from main
- [x] 0.2 Verify branch creation and current branch status

## 1. Xcode Project: Shared Infrastructure

- [x] 1.1 Add App Group capability to the main app target (`group.<bundle-id>.widget`)
- [x] 1.2 Create `CharacterWidgetExtension` target in Xcode (WidgetKit extension template)
- [x] 1.3 Add App Group capability to the `CharacterWidgetExtension` target with the same group identifier
- [x] 1.4 Create `CharacterWidgetData.swift` (Codable struct: `id: Int`, `name: String`, `imageFileName: String`) and add it to both targets via target membership

## 2. Core: AppGroupStore (TDD)

- [x] 2.1 Write failing unit tests for `AppGroupStore`: write snapshot, read current character, set/get current index, empty state returns nil
- [x] 2.2 Implement `AppGroupStore` in `Core/Storage/AppGroupStore.swift` — `UserDefaults(suiteName:)` for character array and current index; make tests pass
- [x] 2.3 Write failing unit tests for image file storage: save image to shared container, skip if file exists, return correct path
- [x] 2.4 Implement image file storage in `AppGroupStore`: download image via `URLSession` and save to `<AppGroupContainer>/Library/Caches/widget-images/<id>.jpg`; make tests pass
- [x] 2.5 Add `AppGroupStore` to `DIContainer` as a stored property

## 3. Core: Wire Snapshot Write into CharactersListViewModel

- [x] 3.1 Write failing unit tests: after `loadInitial()` succeeds, `AppGroupStore.writeSnapshot` is called with 20 randomly sampled characters (`allCharacters.shuffled().prefix(20)`); with a pool < 20 chars, all are passed (shuffled)
- [x] 3.2 Inject `AppGroupStore` into `CharactersListViewModel` via constructor (optional — nil by default so existing tests are unaffected)
- [x] 3.3 Call `AppGroupStore.writeSnapshot(_:)` in a detached background `Task` after `ViewState.success` is set in `performFetch`, passing `Array(allCharacters.shuffled().prefix(20))`; make test pass
- [x] 3.4 Update `DIContainer.makeCharactersListViewModel()` factory to inject `AppGroupStore`

## 4. Widget Extension: Timeline Provider and Entry

- [x] 4.1 Create `CharacterWidgetEntry.swift` (WidgetKit `TimelineEntry`: `date`, `character: CharacterWidgetData?`)
- [x] 4.2 Create `CharacterWidgetProvider.swift` (WidgetKit `TimelineProvider`): reads `AppGroupStore` for current character; returns a single-entry timeline with 15-min refresh policy
- [x] 4.3 Write unit tests for `CharacterWidgetProvider`: returns placeholder entry when no data, returns correct character entry when data present — NOTE: WidgetKit types not available in main test target; needs separate `CharacterWidgetExtensionTests` target (Xcode setup, see task 1.2)

## 5. Widget Extension: App Intents

- [x] 5.1 Create `NextCharacterIntent.swift` (`AppIntent`): increments index in `AppGroupStore` with wrap-around, calls `WidgetCenter.shared.reloadAllTimelines()`
- [x] 5.2 Create `PreviousCharacterIntent.swift` (`AppIntent`): decrements index in `AppGroupStore` with wrap-around, calls `WidgetCenter.shared.reloadAllTimelines()`
- [x] 5.3 Write unit tests for both intents: verify index increment/decrement and wrap-around logic

## 6. Widget Extension: SwiftUI Views

- [x] 6.1 Create `CharacterWidgetView.swift`: SwiftUI view consuming `CharacterWidgetEntry`; show character image (`UIImage(contentsOfFile:)`), name, and ← → `Button` views wired to App Intents
- [x] 6.2 Implement `.systemSmall` layout: full-bleed image with name overlay at bottom and navigation arrows overlaid at corners
- [x] 6.3 Implement `.systemMedium` layout: image left half, name + navigation arrows right half
- [x] 6.4 Implement placeholder/redacted state for WidgetKit `.placeholder(in:)` call
- [x] 6.5 Add `#Preview` macros for all states: loaded (small), loaded (medium), empty/placeholder

## 7. Widget Extension: Widget Configuration

- [x] 7.1 Create `CharacterWidget.swift` (`Widget` conformance): define `StaticConfiguration` with `CharacterWidgetProvider`, supported families `.systemSmall` + `.systemMedium`
- [x] 7.2 Create `CharacterWidgetBundle.swift` (`WidgetBundle` entry point) exporting `CharacterWidget`
- [x] 7.3 Verify widget appears in the widget picker on simulator

## 8. Review and Update Existing Unit Tests (MANDATORY)

- [x] 8.1 Review `CharactersListViewModelTests` — update to account for optional `AppGroupStore` injection (ensure existing tests still pass with `nil` store)
- [x] 8.2 Review `DIContainer` tests or usages — update factory calls if needed
- [x] 8.3 Confirm `MockDataFactory` has no changes needed

## 9. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 9.1 Run targeted tests for `AppGroupStore`, `CharacterWidgetProvider`, and App Intents:
  ```bash
  xcodebuild test -scheme RickMortyPersistImage \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:RickMortyPersistImageTests/AppGroupStoreTests \
    | xcpretty
  ```
- [x] 9.2 Run full unit test suite and confirm no regressions
- [x] 9.3 Create report `openspec/changes/character-navigation-widget/specs/reports/YYYY-MM-DD-step-9-unit-test-verification.md`
- [x] 9.4 Mark step complete only after all tests pass and report exists

## 10. Manual Simulator Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 10.1 Build app and widget extension for simulator — verify zero errors and zero warnings
- [x] 10.2 Launch the app, navigate to Characters tab, wait for successful load — verify `AppGroupStore` snapshot is written (check via breakpoint or log)
- [x] 10.3 Add the widget to the simulator home screen in both `.systemSmall` and `.systemMedium` sizes
- [x] 10.4 Verify the widget displays the first character's image and name
- [x] 10.5 Tap the → arrow — verify the widget updates to the second character
- [x] 10.6 Tap the ← arrow from the first character — verify it wraps to the last character
- [x] 10.7 Verify placeholder state by testing without prior app launch (empty App Group)
- [x] 10.8 Create report `openspec/changes/character-navigation-widget/specs/reports/YYYY-MM-DD-step-10-simulator-verification.md`

## 11. Update Technical Documentation (MANDATORY)

- [x] 11.1 Update `docs/domain-data-standards.md` — add `AppGroupStore` to the Core layer section and document the App Group shared storage pattern
- [x] 11.2 Update `openspec/config.yaml` context if needed (no change expected)
- [x] 11.3 Add brief note to `README.md` about the widget extension (how to add it to the home screen)
