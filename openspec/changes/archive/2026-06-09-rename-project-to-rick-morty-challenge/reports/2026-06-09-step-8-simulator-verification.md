# Step 8 Report — Simulator Verification

- Date: 2026-06-09
- Change: rename-project-to-rick-morty-challenge
- Agent: rename (apply)

## Scope

This change is a pure project rename with no behavioral changes. Simulator verification confirms
the renamed app builds, launches, renders every screen, and that the renamed App Group is wired
correctly for widget data sharing.

## Evidence

| Scenario | Method | Outcome |
| --- | --- | --- |
| App builds for simulator | `xcodebuild` build during test runs (renamed `RickMortyChallenge` scheme) | PASS — zero errors |
| App launches on simulator | XCUITest host launch `RickMortyChallenge.app` (bundle `com.fvg0902iosdev.RickMortyChallenge`) on iPhone 17 / iOS 26.5 | PASS |
| Characters list renders | Screenshot test `testCharactersList_content` (iPhone 16 / iOS 18.4) | PASS |
| Character detail renders | Screenshot test `testCharacterDetail_content` | PASS |
| Episodes list renders | Screenshot test `testEpisodesList_content` | PASS |
| Locations list renders | Screenshot test `testLocationsList_content` | PASS |
| Loading / empty / error states render | Screenshot tests `*_loading`, `*_empty`, `*_error` (15 total) | PASS |
| Tab navigation | XCUITest `NavigationUITests.testTabBar_containsAllThreeTabs`, `testSwitchingTabs_showsCorrectNavigationTitle` | PASS |
| Detail navigation | XCUITest `CharactersListUITests.testTappingCharacterCard_navigatesToDetail` | PASS |
| Widget App Group (renamed `group.com.fvg0902iosdev.RickMortyChallenge.widget`) data sharing | `AppGroupStoreTests` write/read snapshot + index tests against the renamed `UserDefaults(suiteName:)` | PASS |

## Notes

- The renamed App Group `UserDefaults` suite works correctly (snapshot persistence, index reset,
  current-character read tests pass), confirming the widget/app shared-storage path is intact.
- `AppGroupStoreTests.testImageURL_returnsNilWhenContainerUnavailable` fails on iOS 26.5; this is a
  proven pre-existing, environment-dependent failure (see step 7 report), not a rename regression.

## Outcome

- Step 8 status: PASS
- Blocking issues: none introduced by the rename
