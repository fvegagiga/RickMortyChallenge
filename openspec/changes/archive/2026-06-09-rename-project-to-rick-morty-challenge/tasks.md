## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create feature branch `feature/rename-project-to-rick-morty-challenge` from the main branch
- [x] 0.2 Verify branch creation and current branch status
- [ ] 0.3 Commit a clean checkpoint so structural renames can be reverted if needed (skipped — changes left uncommitted for user review; no commit made without explicit request)

## 1. Rename On-Disk Directories and Files (use `git mv`)

- [x] 1.1 `git mv` app source directory `RickMortyPersistImage/` → `RickMortyChallenge/`
- [x] 1.2 `git mv` unit test directory `RickMortyPersistImageTests/` → `RickMortyChallengeTests/`
- [x] 1.3 `git mv` UI test directory `RickMortyPersistImageUITests/` → `RickMortyChallengeUITests/`
- [x] 1.4 `git mv` screenshot test directory `RickMortyPersistImageScreenshotTests/` → `RickMortyChallengeScreenshotTests/`
- [x] 1.5 `git mv` `RickMortyPersistImage.xcodeproj` → `RickMortyChallenge.xcodeproj`
- [x] 1.6 `git mv` `RickMortyPersistImageTests.xctestplan` → `RickMortyChallengeTests.xctestplan`
- [x] 1.7 `git mv` `RickMortyPersistImage/RickMortyPersistImage.entitlements` → `RickMortyChallenge/RickMortyChallenge.entitlements`
- [x] 1.8 `git mv` `RickMortyPersistImage/RickMortyPersistImageApp.swift` → `RickMortyChallenge/RickMortyChallengeApp.swift`

## 2. Update Xcode Project File (`project.pbxproj`)

- [x] 2.1 Update all `path =` and `name =` group/file references to the renamed directories and `.xctestplan`
- [x] 2.2 Update all target `name`/`productName` values to the `RickMortyChallenge` prefix
- [x] 2.3 Update `PRODUCT_BUNDLE_IDENTIFIER` values (`com.fvg0902iosdev.RickMortyPersistImage*` → `com.fvg0902iosdev.RickMortyChallenge*`)
- [x] 2.4 Update `TEST_HOST` and `TEST_TARGET_NAME` references to the renamed app target
- [x] 2.5 Update product reference names (`.app`, `.xctest`) to the `RickMortyChallenge` prefix
- [x] 2.6 Open the project in Xcode and confirm it loads without structural errors

## 3. Update Schemes and Test Plan

- [x] 3.1 Rename the four `.xcscheme` files under `xcshareddata/xcschemes/` to the `RickMortyChallenge` prefix
- [x] 3.2 Update each scheme's `BlueprintName`, `BuildableName`, and `ReferencedContainer` to the renamed targets/container
- [x] 3.3 Update the `RickMortyChallengeTests.xcscheme` test plan `reference` to `container:RickMortyChallengeTests.xctestplan`
- [x] 3.4 Update `RickMortyChallengeTests.xctestplan` `containerPath` and target `name` references

## 4. Update Source, Entitlements, and App Group

- [x] 4.1 Rename the `RickMortyPersistImageApp` struct to `RickMortyChallengeApp` in the renamed app entry file
- [x] 4.2 Update `AppGroupStore.appGroupIdentifier` to `group.com.fvg0902iosdev.RickMortyChallenge.widget`
- [x] 4.3 Update the App Group string in `RickMortyChallenge/RickMortyChallenge.entitlements`
- [x] 4.4 Update the App Group string in `CharacterWidgetExtension/CharacterWidgetExtension.entitlements`
- [x] 4.5 Update the App Group string in `CharacterWidgetExtensionExtension.entitlements`
- [x] 4.6 Replace every `@testable import RickMortyPersistImage` with `@testable import RickMortyChallenge` across all test files

## 5. Update CI, Documentation, and Diagram

- [x] 5.1 Update `.github/workflows/ios-tests.yml` `-project` and `-scheme` references to the renamed project/schemes
- [x] 5.2 Update `README.md` references to `RickMortyPersistImage`
- [x] 5.3 Update live docs (`docs/*`, `ai-specs/skills/*`) references to the new name
- [x] 5.4 Update the architecture diagram (`RickMortyArchitecture.drawio`) labels referencing the old name
- [x] 5.5 Update the live spec `openspec/specs/ui-screenshot-regression-tests/spec.md` target name to `RickMortyChallengeScreenshotTests`

## 6. Review and Update Existing Unit Tests (MANDATORY)

- [x] 6.1 Confirm all renamed test targets compile against the renamed module
- [x] 6.2 Confirm mocks and helpers reference the renamed module and App Group correctly
- [x] 6.3 Run a repo-wide search for `RickMortyPersistImage` excluding `openspec/changes/archive/**` and confirm zero matches

## 7. Run Unit + Screenshot Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 7.1 Clean build folder / DerivedData to clear stale product names
- [x] 7.2 Run `xcodebuild test -scheme RickMortyChallenge -destination 'platform=iOS Simulator,name=iPhone 16'`
- [x] 7.3 Run `xcodebuild test -scheme RickMortyChallengeScreenshotTests -destination 'platform=iOS Simulator,name=iPhone 16'`
- [x] 7.4 Create report `specs/rename-project-to-rick-morty-challenge/reports/YYYY-MM-DD-step-7-unit-test-verification.md`
- [x] 7.5 Mark step complete only after all tests pass and the report exists

## 8. Manual Simulator Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 8.1 Build the app for the simulator with the renamed scheme — verify zero errors and warnings
- [x] 8.2 Launch the app with the new bundle identifier and verify Characters/Episodes/Locations load
- [x] 8.3 Verify the widget App Group data sharing works with the renamed App Group identifier
- [x] 8.4 Create report `specs/rename-project-to-rick-morty-challenge/reports/YYYY-MM-DD-step-8-simulator-verification.md`

## 9. XCUITest Automated UI Tests (MANDATORY — AGENT MUST EXECUTE)

- [x] 9.1 Run `xcodebuild test -scheme RickMortyChallenge -only-testing:RickMortyChallengeUITests -destination 'platform=iOS Simulator,name=iPhone 16'`
- [x] 9.2 Verify app launch and core navigation flows pass
- [x] 9.3 Create report `specs/rename-project-to-rick-morty-challenge/reports/YYYY-MM-DD-step-9-xcuitest-verification.md`

## 10. Update Technical Documentation (MANDATORY)

- [x] 10.1 Verify all live documentation reflects the `RickMortyChallenge` name consistently
- [x] 10.2 Update `openspec/config.yaml` context/examples if they reference the old project name
- [x] 10.3 Confirm no broken symlinks or stale references remain after the rename
