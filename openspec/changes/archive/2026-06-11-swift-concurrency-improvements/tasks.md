## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/swift-concurrency-improvements` from main branch
- [x] 0.2 Verify branch creation and current branch status with `git status`

## 1. Core: Thread-safe image cache (TDD)

- [x] 1.1 Add failing `ImageCacheManagerTests` in `RickMortyChallengeTests` covering memory hit, disk hit, clear, and parallel store/read via `withTaskGroup` (spec: `thread-safe-image-cache`)
- [x] 1.2 Update `ImageCacheManagerProtocol` to declare `async` methods: `image(for:)`, `store(_:for:)`, `clearCache()`
- [x] 1.3 Convert `ImageCacheManager` to `actor ImageCacheManager`; move disk writes inside actor isolation (remove unstructured background `Task` from external callers)
- [x] 1.4 Update `CachedAsyncImageView.loadImage()` to `await` cache lookup and store
- [x] 1.5 Confirm `DIContainer` still wires a shared `ImageCacheManager` instance as `ImageCacheManagerProtocol`
- [x] 1.6 Run `ImageCacheManagerTests` until green

## 2. Core: Thread-safe app group store (TDD)

- [x] 2.1 Update `AppGroupStoreProtocol`: async `writeSnapshot` and `downloadImages`; keep or adjust read helpers for widget sync access per design (spec: `thread-safe-app-group-store`)
- [x] 2.2 Convert `AppGroupStore` to `actor AppGroupStore`; preserve snapshot reset, image path, skip-existing download behaviour
- [x] 2.3 Update `MockAppGroupStore` to match the new async protocol surface
- [x] 2.4 Update `AppGroupStoreTests` for async/actor APIs; ensure all existing behavioural tests pass
- [x] 2.5 Update `CharacterWidgetProvider` call sites if read/write signatures change (WidgetKit completion APIs unchanged)

## 3. Presentation: Structured ViewModel tasks (TDD)

- [x] 3.1 Update failing `CharactersListViewModelWidgetTests` expectations for async store interactions if needed
- [x] 3.2 Replace `Task.detached` in `CharactersListViewModel.writeWidgetSnapshot()` with `Task { @concurrent in await store.downloadImages(for:) }` and `await store.writeSnapshot` (spec: `viewmodel-structured-tasks`)
- [x] 3.3 Refactor `onSearchTextChanged()` debounce to sleep off main actor (`Task { @concurrent in ... }`) and hop to `@MainActor` for `performSearch()`
- [x] 3.4 Run `CharactersListViewModelTests` and `CharactersListViewModelWidgetTests` until green

## 4. Review and Update Existing Unit Tests (MANDATORY)

- [x] 4.1 Review and update any tests referencing synchronous cache or store APIs (`CharacterNavigationIntentTests`, screenshot helpers if affected)
- [x] 4.2 Run Domain/Data coverage check: `python3 scripts/check-domain-data-coverage.py` — confirm ≥ 90% line coverage unchanged or improved
- [x] 4.3 Fix any compiler concurrency warnings introduced in modified files

## 5. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 5.1 Run targeted tests:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeTests/ImageCacheManagerTests -only-testing:RickMortyChallengeTests/AppGroupStoreTests -only-testing:RickMortyChallengeTests/CharactersListViewModelWidgetTests -only-testing:RickMortyChallengeTests/CharactersListViewModelTests | xcpretty`
- [x] 5.2 Run full unit test suite:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeTests | xcpretty`
- [x] 5.3 Create report `openspec/changes/swift-concurrency-improvements/reports/2026-06-11-step-5-unit-test-verification.md`
- [x] 5.4 Mark step complete only after all tests pass and report exists

## 6. Manual Simulator Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 6.1 Build the app for simulator:
  `xcodebuild build -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty`
- [x] 6.2 Launch app → Characters tab: verify list images load (cache + network), scroll pagination, pull-to-refresh
- [x] 6.3 Type in search field: verify debounced results update without UI jank
- [x] 6.4 After characters load, confirm widget snapshot side effect does not block UI (list remains responsive)
- [x] 6.5 Spot-check Locations and Episodes tabs still load (unaffected but regression guard)
- [x] 6.6 Create report `openspec/changes/swift-concurrency-improvements/reports/2026-06-11-step-6-simulator-verification.md`

## 7. XCUITest Automated UI Tests (MANDATORY — AGENT MUST EXECUTE)

- [x] 7.1 Run existing UI tests (no new flows; regression guard for Presentation changes):
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeUITests | xcpretty`
- [x] 7.2 If screenshot timing changes affect baselines, run `RickMortyChallengeScreenshotTests` and update baselines only for intentional diffs
- [x] 7.3 Create report `openspec/changes/swift-concurrency-improvements/reports/2026-06-11-step-7-xcuitest-verification.md`

## 8. Update Technical Documentation (MANDATORY)

- [x] 8.1 Update `docs/project-profile.md` Core concurrency notes (image cache and app group store actor isolation) if the profile documents these types
- [x] 8.2 Add a brief concurrency subsection to `docs/advanced-topics.md` Swift 6 reference noting applied actor patterns (optional cross-link only; do not enable Swift 6)
- [x] 8.3 Sync main specs from change deltas at archive time via `/opsx:sync` or `/opsx:archive`
