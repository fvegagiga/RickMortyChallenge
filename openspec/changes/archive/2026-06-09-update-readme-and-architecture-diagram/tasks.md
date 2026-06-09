## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/update-readme-and-architecture-diagram` from main
- [x] 0.2 Verify branch creation with `git status`

## 1. README: Add Features Section

- [x] 1.1 Add **Features** section after Screenshots documenting Characters tab (grid, search with debounce, detail, pagination, pull-to-refresh, states)
- [x] 1.2 Document Locations tab (list, pagination, pull-to-refresh, states — no search/detail)
- [x] 1.3 Document Episodes tab (list, season-coded badges, pagination, pull-to-refresh, states — no search/detail)
- [x] 1.4 Document Home Screen Widget (sizes, ← → navigation, App Group sync, placeholder state)

## 2. README: Fix Stale References and Tech Stack

- [x] 2.1 Update Tech Stack table: Network SPM package, iOS 16.6, App Group, CI
- [x] 2.2 Fix Project Structure tree: remove `AppRoute.swift` and local `NetworkService*` files; add `Core/Storage/`, `CharacterWidgetExtension/`, `RickMortyChallengeScreenshotTests/`
- [x] 2.3 Update Architecture section: reference `RickMortyArchitecture.drawio` with draw.io instructions; fix Data layer description (SPM + `APIEndpoint.swift` only)
- [x] 2.4 Update Testing Strategy: add Storage and Widget unit test folders, note test gaps honestly
- [x] 2.5 Update Widget section: reflect that Xcode targets are already configured; fix target naming
- [x] 2.6 Add CI/CD section referencing `.github/workflows/ios-tests.yml`

## 3. Architecture Diagram: Simplify RickMortyArchitecture.drawio

- [x] 3.1 Replace diagram with simplified layer-box layout (~900×700 px, no edges, no legend)
- [x] 3.2 Include four layers (Presentation, Domain, Data, Core) with bullet-list components per design.md
- [x] 3.3 Add external systems box (Rick & Morty API, Network SPM, App Group) and widget extension box
- [x] 3.4 Verify diagram opens correctly in draw.io and is readable at 100% zoom

## 4. Review and Update Existing Unit Tests (MANDATORY)

- [x] 4.1 Confirm no Swift source files were modified (documentation-only change)
- [x] 4.2 Review that no test updates are required

## 5. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 5.1 Run full unit test suite:
  ```bash
  xcodebuild test \
    -project RickMortyChallenge.xcodeproj \
    -scheme RickMortyChallenge \
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' \
    | xcpretty
  ```
- [x] 5.2 Create report `openspec/changes/update-readme-and-architecture-diagram/reports/2026-06-09-step-5-unit-test-verification.md`
- [x] 5.3 Mark step complete only after all tests pass and report exists

## 6. Documentation Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 6.1 Cross-check README Features section against live codebase (all tabs, widget, shared components)
- [x] 6.2 Cross-check README Project Structure against actual file tree (`find` or directory listing)
- [x] 6.3 Cross-check architecture diagram naming (`MainTabView`, `CachedAsyncImageView`, `CharacterRoute`, `AppGroupStore`)
- [x] 6.4 Create report `openspec/changes/update-readme-and-architecture-diagram/reports/2026-06-09-step-6-documentation-verification.md`

## 7. Update Technical Documentation (MANDATORY — LAST STEP)

- [x] 7.1 Final read-through of `README.md` for English, formatting, and consistency with `docs/documentation-standards.md`
- [x] 7.2 Confirm `RickMortyArchitecture.drawio` matches `project-documentation` spec requirements
- [x] 7.3 Mark all tasks complete in this file

**Skipped mandatory steps (not applicable):**
- Simulator verification — no Presentation layer code changes
- XCUITest — no UI flow changes
