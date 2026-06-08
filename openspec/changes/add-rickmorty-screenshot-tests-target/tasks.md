## 0. Branch Setup

- [x] 0.1 Create feature branch `feature/add-rickmorty-screenshot-tests-target`

## 1. Screenshot Target Foundation

- [x] 1.1 Add the `RickMortyPersistImageScreenshotTests` target to the Xcode project and wire required build settings
- [x] 1.2 Add and configure snapshot testing dependency for the new target (or reuse existing one if already present)
- [x] 1.3 Implement deterministic screenshot harness (fixed device, locale, appearance, and content size)
- [x] 1.4 Exclude approved baseline PNG files from the screenshot test bundle resources
- [x] 1.5 Disable production app bootstrap while screenshot tests run inside the host app

## 2. Screen Coverage Implementation

- [x] 2.1 Inventory all production screens and define one screenshot suite per screen entry point
- [x] 2.2 Add screenshot tests for primary visual states of each screen (content, loading, empty, error where applicable)
- [x] 2.3 Create and commit initial approved screenshot baselines for all covered screens
- [x] 2.4 Ensure screenshot baselines render visible SwiftUI content and are not blank images
- [x] 2.5 Render screenshots through a hosted UIKit lifecycle so full SwiftUI screens are captured instead of isolated placeholders

## 3. Regression Workflow Integration

- [x] 3.1 Integrate screenshot target execution into CI using the same deterministic simulator profile as local runs
- [x] 3.2 Document baseline refresh workflow for intentional UI updates in project technical docs

## 4. Mandatory Verification

- [x] 4.1 Run `xcodebuild test` including the screenshot target and save the report under `openspec/changes/add-rickmorty-screenshot-tests-target/specs/ui-screenshot-regression-tests/reports/`
- [x] 4.2 Perform simulator verification for all app screens to confirm screenshot assertions match expected UI states
- [ ] 4.3 Run XCUITest flows to ensure screenshot test additions do not regress existing UI behavior checks

## 5. Finalization

- [x] 5.1 Update Technical Documentation with the new screenshot target, coverage scope, and execution instructions
