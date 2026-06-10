## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/fix-character-detail-gradient-overlay` from main branch
- [x] 0.2 Verify branch creation and current branch status with `git status`

## 1. Presentation: Fix hero gradient overlay layout

- [x] 1.1 Refactor `CharacterDetailContentBodyView.heroSection` in `CharacterDetailView.swift`: replace the current `.overlay(alignment: .bottomLeading)` with a `ZStack(alignment: .bottomLeading)` containing a full-width gradient layer (`.frame(maxWidth: .infinity, height: 160, alignment: .bottom)`) and the existing text `VStack` on top
- [x] 1.2 Preserve existing hero modifiers: image fill, `.frame(height: 340)`, `.clipped()`, gradient colors `[.black.opacity(0.7), .clear]`, and `DSSpacing.md` padding on text
- [x] 1.3 Verify `#Preview` or SwiftUI canvas compiles for `CharacterDetailContentBodyView` if present; otherwise confirm project builds without errors

## 2. Screenshot Regression: Update Character Detail baseline

- [x] 2.1 Run `testCharacterDetail_content` in `RickMortyChallengeScreenshotTests`:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeScreenshotTests/ScreenshotRegressionTests/testCharacterDetail_content | xcpretty`
- [x] 2.2 If the visual diff is intentional (full-width gradient), regenerate and commit the updated `CharacterDetail_Content` baseline per the documented snapshot workflow
- [x] 2.3 Re-run the test to confirm it passes with the new baseline

## 3. Review and Update Existing Unit Tests (MANDATORY)

- [x] 3.1 Review `CharacterDetailViewModelTests` — confirm no changes needed (layout-only fix)
- [x] 3.2 Confirm no Domain/Data tests are affected by this Presentation-layer change

## 4. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 4.1 Run targeted unit tests:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeTests/CharacterDetailViewModelTests | xcpretty`
- [x] 4.2 Run full unit test suite:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeTests | xcpretty`
- [x] 4.3 Create report `openspec/changes/fix-character-detail-gradient-overlay/reports/2026-06-10-step-4-unit-test-verification.md`
- [x] 4.4 Mark step complete only after all tests pass and report exists

## 5. Manual Simulator Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 5.1 Build the app for simulator:
  `xcodebuild build -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty`
- [x] 5.2 Launch the app, navigate Characters tab → tap any character → verify full-width bottom gradient on hero image
- [x] 5.3 Verify status badge and character name remain legible and bottom-leading aligned in light mode
- [x] 5.4 Repeat verification in dark mode (Settings → Appearance → Dark)
- [x] 5.5 Confirm loading, error, and empty states of `CharacterDetailView` are unchanged (spot-check if feasible)
- [x] 5.6 Create report `openspec/changes/fix-character-detail-gradient-overlay/reports/2026-06-10-step-5-simulator-verification.md`

## 6. XCUITest Automated UI Tests (SKIPPED)

- [x] 6.1 **Skipped** — no user flow or interaction changes; existing `accessibilityIdentifier("character-detail")` unchanged. Rationale recorded per `docs/openspec-tasks-mandatory-steps.md`.

## 7. Update Technical Documentation (MANDATORY)

- [x] 7.1 Sync `openspec/specs/character-detail-view/spec.md` from the change delta at archive time (or via `/opsx:sync` if archiving with sync)
- [x] 7.2 Update `README.md` only if the Character Detail section needs a note about hero layout (likely not required for this bug fix)
