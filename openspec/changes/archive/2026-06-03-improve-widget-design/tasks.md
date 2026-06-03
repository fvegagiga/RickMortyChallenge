## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/improve-widget-design` from main branch
- [x] 0.2 Verify branch creation and current branch status with `git status`

## 1. Core: Extend CharacterWidgetData with status field (TDD)

- [x] 1.1 Write failing unit test in `AppGroupStoreTests` asserting that a decoded `CharacterWidgetData` with no `status` key defaults to empty string
- [x] 1.2 Add `status: String` to `CharacterWidgetData` with `CodingKeys` default of `""` to make the test pass
- [x] 1.3 Write failing test asserting that a `CharacterWidgetData` encoded with `status: "Alive"` round-trips correctly
- [x] 1.4 Run targeted tests to confirm the new tests pass and no regressions in `AppGroupStoreTests`

## 2. Presentation: Pass status when creating CharacterWidgetData (TDD)

- [x] 2.1 Write failing test in `CharactersListViewModelWidgetTests` asserting that the `CharacterWidgetData` snapshot includes the character's `status` value
- [x] 2.2 Update `CharactersListViewModel` (line 88) to include `status: $0.status` (or equivalent `Character` entity field) when constructing `CharacterWidgetData`
- [x] 2.3 Run targeted tests to confirm `CharactersListViewModelWidgetTests` passes

## 3. Widget Extension: Add index fields to CharacterWidgetEntry

- [x] 3.1 Add `currentIndex: Int` and `totalCount: Int` to `CharacterWidgetEntry` with defaults of `0` and `0`
- [x] 3.2 Update all existing `CharacterWidgetEntry` initialisers in previews (`CharacterWidgetView.swift`) and tests to supply the new fields (use `currentIndex: 0, totalCount: 1` as safe defaults)

## 4. Widget Extension: Update CharacterWidgetProvider to populate index fields

- [x] 4.1 Update `getSnapshot` to pass `currentIndex` and `totalCount` from `store` into `CharacterWidgetEntry`
- [x] 4.2 Update `getTimeline` to pass `currentIndex` and `totalCount` from `store` into `CharacterWidgetEntry`
- [x] 4.3 Verify `AppGroupStoreProtocol` exposes `currentIndex()` and `totalCharacters()` (add if missing)

## 5. Widget Extension: Redesign CharacterWidgetView (Presentation Layer — TDD)

- [x] 5.1 Add a private `statusColor` computed property to `CharacterWidgetView` that maps `entry.character?.status` → `Color.DS.statusAlive / statusDead / statusUnknown`
- [x] 5.2 Update `nameLabel` to use `Font.DS.caption` token and add the status dot (`Circle().fill(statusColor).frame(width: 8, height: 8)`) in an `HStack`
- [x] 5.3 Update the navigation bar to include a centered index label (`"\(entry.currentIndex + 1) / \(entry.totalCount)"`) using `Font.DS.caption2` between the chevrons; apply `Color.DS.portalGreen` foreground to both chevron buttons
- [x] 5.4 Replace `Image(systemName: "chevron.left/right").font(.caption.weight(.bold))` with DS-token equivalents
- [x] 5.5 Improve `smallLayout`: replace `.ultraThinMaterial` band with a bottom gradient overlay (`LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)`) for better legibility on bright character images
- [x] 5.6 Update `mediumLayout` to use `DSSpacing` constants (replace hardcoded `padding(12)` and `spacing: 12`)
- [x] 5.7 Update the placeholder view (no character data) to show `Image(systemName: "person.fill")` with caption text "Open the app to load characters"
- [x] 5.8 Update `#Preview` macros to cover: small loaded, small placeholder, medium loaded, medium placeholder — verify they compile and render

## 6. Review and Update Existing Unit Tests (MANDATORY)

- [x] 6.1 Review `CharacterNavigationIntentTests` for regressions from `CharacterWidgetEntry` changes and update as needed
- [x] 6.2 Review `CharactersListViewModelWidgetTests` to ensure all assertions still pass with the `status` field
- [x] 6.3 Update `MockAppGroupStore` if it needs to surface `currentIndex()` or `totalCharacters()`

## 7. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 7.1 Run targeted tests for modified modules:
  `xcodebuild test -scheme RickMortyPersistImage -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyPersistImageTests/AppGroupStoreTests -only-testing:RickMortyPersistImageTests/CharactersListViewModelWidgetTests -only-testing:RickMortyPersistImageTests/CharacterNavigationIntentTests | xcpretty`
- [x] 7.2 Run full unit test suite:
  `xcodebuild test -scheme RickMortyPersistImage -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty`
- [x] 7.3 Create report `openspec/changes/improve-widget-design/reports/YYYY-MM-DD-step-7-unit-test-verification.md`
- [x] 7.4 Mark step complete only after all tests pass and report exists

## 8. Manual Simulator Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 8.1 Build the widget extension for simulator — verify zero errors:
  `xcodebuild build -scheme RickMortyPersistImage -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty`
- [x] 8.2 Boot simulator and launch the app to trigger App Group data population
- [x] 8.3 Add widget to home screen in the simulator and verify systemSmall layout: gradient overlay visible, status dot correct colour, index counter shows "1 / N", portal-green chevrons visible
- [x] 8.4 Verify systemMedium layout: image on left, name + status dot + index counter + portal-green chevrons on right with correct spacing
- [x] 8.5 Verify placeholder state (no characters stored): `person.fill` icon and "Open the app to load characters" text visible in both sizes
- [x] 8.6 Tap next/previous chevrons and verify index counter updates correctly
- [x] 8.7 Create report `openspec/changes/improve-widget-design/reports/YYYY-MM-DD-step-8-simulator-verification.md`

## 9. Update Technical Documentation (MANDATORY)

- [x] 9.1 Update `openspec/specs/character-widget/spec.md` with the archived delta from `specs/character-widget/spec.md` (apply MODIFIED requirements)
- [x] 9.2 Create `openspec/specs/widget-character-status-indicator/spec.md` from the new capability spec
- [x] 9.3 Create `openspec/specs/widget-index-counter/spec.md` from the new capability spec
- [x] 9.4 Update `docs/presentation-standards.md` if the widget's design system adoption introduces a new pattern worth documenting
