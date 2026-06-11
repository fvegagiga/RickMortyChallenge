## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/fix-characters-list-onchange-deprecation` from main branch
- [x] 0.2 Verify branch creation and current branch status with `git status`

## 1. Presentation: Migrate deprecated `onChange` in CharactersListView

- [x] 1.1 In `RickMortyChallenge/Presentation/Characters/Views/CharactersListView.swift`, replace `.onChange(of: viewModel.searchText) { _ in viewModel.onSearchTextChanged() }` with the iOS 17+ zero-parameter closure: `.onChange(of: viewModel.searchText) { viewModel.onSearchTextChanged() }`
- [x] 1.2 Build the project and confirm the deprecation warning for `CharactersListView` is resolved:
  `xcodebuild build -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty`

## 2. Review and Update Existing Unit Tests (MANDATORY)

- [x] 2.1 Review `CharactersListViewModelTests` — confirm existing search/debounce tests still apply; no test changes expected
- [x] 2.2 Confirm no Domain/Data tests are affected by this Presentation-layer API modernization

## 3. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 3.1 Run targeted unit tests:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeTests/CharactersListViewModelTests | xcpretty`
- [x] 3.2 Run full unit test suite:
  `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickMortyChallengeTests | xcpretty`
- [x] 3.3 Create report `openspec/changes/fix-characters-list-onchange-deprecation/reports/2026-06-11-step-3-unit-test-verification.md`
- [x] 3.4 Mark step complete only after all tests pass and report exists

## 4. Manual Simulator Verification (SKIPPED)

- [x] 4.1 **Skipped** — compiler-warning fix only; no user-visible or interaction changes. Rationale recorded per `docs/openspec-tasks-mandatory-steps.md` and `design.md`.

## 5. XCUITest Automated UI Tests (SKIPPED)

- [x] 5.1 **Skipped** — search flow and accessibility identifiers unchanged. Rationale recorded per `docs/openspec-tasks-mandatory-steps.md`.

## 6. Update Technical Documentation (MANDATORY)

- [x] 6.1 Confirm no main spec sync required (`specs/no-requirement-delta.md` — no requirement changes)
- [x] 6.2 Update `README.md` only if needed (not expected for this one-line API fix)
