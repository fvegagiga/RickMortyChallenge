## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/swift-concurrency-follow-ups` from main branch
- [x] 0.2 Verify branch creation and current branch status with `git status`

## 1. Spec and documentation alignment (no runtime changes)

- [x] 1.1 Add two-key `UserDefaults` invariant comment to `AppGroupStore.swift` explaining `nonisolated` widget reads (spec: `thread-safe-app-group-store`)
- [x] 1.2 Verify delta specs match design: `thread-safe-app-group-store`, `thread-safe-image-cache`, `viewmodel-structured-tasks`, `character-data-sharing`

## 2. Core: AppGroupStore downloadImages tests (TDD)

- [x] 2.1 Add test helper: `URLProtocol` stub (or session request counter) for injectable `URLSession` in `AppGroupStoreTests`
- [x] 2.2 Write failing test `downloadImages_skipsExistingFile` — pre-create `{id}.jpg`, assert no network request (spec: `thread-safe-app-group-store`)
- [x] 2.3 Write failing test `downloadImages_downloadsWhenMissing` — stub network response, assert file written
- [x] 2.4 Write failing test `downloadImages_parallelCompletion` — concurrent invocation completes without crash and files exist
- [x] 2.5 Implement any minimal production changes needed to make tests pass (prefer test-only; no behaviour change)
- [x] 2.6 Run `AppGroupStoreTests` until green

## 3. Presentation: Debounce tests (TDD)

- [x] 3.1 Write failing test `onSearchTextChanged_cancelsPriorDebounce` in `CharactersListViewModelTests` — double call before 500 ms, assert no fetch (spec: `viewmodel-structured-tasks`)
- [x] 3.2 Write failing test `onSearchTextChanged_triggersSearchAfterDebounce` — single call, wait >500 ms, assert fetch and `viewState` update
- [x] 3.3 Run debounce tests until green (ViewModel code likely unchanged)

## 4. Test hygiene and strengthened assertions

- [x] 4.1 Add `downloadImagesCallCount == 1` assertion to `CharactersListViewModelWidgetTests` after successful `loadInitial()` with brief yield for fire-and-forget task (spec: `viewmodel-structured-tasks`)
- [x] 4.2 Strengthen `ImageCacheManagerTests.parallelStoreAndRead` to assert per-URL image correctness (distinct colours), not merely non-nil (spec: `thread-safe-image-cache`)
- [x] 4.3 Wrap `ImageCacheManager.clearMemoryCacheForTesting()` in `#if DEBUG` (spec: `thread-safe-image-cache`)
- [x] 4.4 Run `CharactersListViewModelWidgetTests` and `ImageCacheManagerTests` until green

## 5. Review and Update Existing Unit Tests (MANDATORY)

- [x] 5.1 Review existing tests for regressions after `#if DEBUG` wrap and new test helpers
- [x] 5.2 Run Domain/Data coverage check: `python3 scripts/check-domain-data-coverage.py TestResults.xcresult` — confirm ≥ 90% line coverage unchanged or improved
- [x] 5.3 Fix any compiler warnings introduced in modified files

## 6. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 6.1 Run targeted tests:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,id=2889153C-BBD1-429C-AB56-7E85CF69CB8C' -only-testing:RickMortyChallengeTests/AppGroupStoreTests -only-testing:RickMortyChallengeTests/CharactersListViewModelTests -only-testing:RickMortyChallengeTests/CharactersListViewModelWidgetTests -only-testing:RickMortyChallengeTests/ImageCacheManagerTests -resultBundlePath TestResults.xcresult | xcpretty`
- [x] 6.2 Run full unit test suite:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,id=2889153C-BBD1-429C-AB56-7E85CF69CB8C' -only-testing:RickMortyChallengeTests -resultBundlePath TestResults.xcresult | xcpretty`
- [x] 6.3 Create report `openspec/changes/swift-concurrency-follow-ups/reports/2026-06-11-step-6-unit-test-verification.md`
- [x] 6.4 Mark step complete only after all tests pass and report exists

## 7. Manual Simulator Verification (SKIPPED — test-only change)

N+2 skipped: No user-visible Presentation behaviour changes; only tests, `#if DEBUG` visibility, and spec/doc alignment. Rationale recorded per `docs/openspec-tasks-mandatory-steps.md`.

## 8. XCUITest Automated UI Tests (MANDATORY — AGENT MUST EXECUTE — regression guard)

- [x] 8.1 Run existing UI tests (no new flows; regression guard):
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,id=2889153C-BBD1-429C-AB56-7E85CF69CB8C' -only-testing:RickMortyChallengeUITests | xcpretty`
- [x] 8.2 Create report `openspec/changes/swift-concurrency-follow-ups/reports/2026-06-11-step-8-xcuitest-verification.md`

## 9. Update Technical Documentation (MANDATORY)

- [x] 9.1 Update `docs/advanced-topics.md` if concurrency subsection needs cross-link to revised isolation wording
- [x] 9.2 Sync main specs from change deltas at archive time via `/opsx:archive`
