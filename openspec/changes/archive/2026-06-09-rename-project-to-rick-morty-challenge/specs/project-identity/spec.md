## ADDED Requirements

### Requirement: Canonical project name
The project SHALL use `RickMortyChallenge` as its canonical name for the Xcode project file,
the app target, the source module/group, and the top-level source directory. The legacy name
`RickMortyPersistImage` MUST NOT appear in any live (non-archived) project artifact.

#### Scenario: Xcode project uses the canonical name
- **WHEN** a developer opens the workspace
- **THEN** the Xcode project is named `RickMortyChallenge.xcodeproj` and the app target is `RickMortyChallenge`

#### Scenario: Source module is renamed
- **WHEN** test targets import the app module under test
- **THEN** they use `@testable import RickMortyChallenge` and the app source lives under `RickMortyChallenge/`

#### Scenario: No live references to the legacy name remain
- **WHEN** the repository is searched for `RickMortyPersistImage` excluding `openspec/changes/archive/**`
- **THEN** no matches are found

---

### Requirement: Canonical test target names
All test targets SHALL be named using the `RickMortyChallenge` prefix
(`RickMortyChallengeTests`, `RickMortyChallengeUITests`, `RickMortyChallengeScreenshotTests`)
and their directories, schemes, and test plan MUST reference these names consistently.

#### Scenario: Test targets are renamed
- **WHEN** a developer inspects the project test targets
- **THEN** the unit, UI, and screenshot test targets use the `RickMortyChallenge` prefix and build successfully

#### Scenario: Schemes and test plan reference renamed targets
- **WHEN** the shared schemes and the test plan are loaded
- **THEN** their `BlueprintName`, `BuildableName`, `ReferencedContainer`, `TEST_HOST`, `TEST_TARGET_NAME`, and container paths reference the renamed project and targets

---

### Requirement: Canonical bundle and App Group identifiers
The product bundle identifiers SHALL use the `com.fvg0902iosdev.RickMortyChallenge` base, and
the shared App Group identifier SHALL be `group.com.fvg0902iosdev.RickMortyChallenge.widget`.
The app and the Widget extension MUST reference the same renamed App Group so shared storage
continues to function.

#### Scenario: Bundle identifiers use the canonical base
- **WHEN** the app and test targets are built
- **THEN** their `PRODUCT_BUNDLE_IDENTIFIER` values start with `com.fvg0902iosdev.RickMortyChallenge`

#### Scenario: App Group is renamed consistently
- **WHEN** the app writes widget data and the Widget extension reads it
- **THEN** both use `group.com.fvg0902iosdev.RickMortyChallenge.widget` and shared data is exchanged successfully

---

### Requirement: Renamed project builds and passes tests
After the rename, the project SHALL build and all existing automated tests SHALL pass without
behavioral changes.

#### Scenario: Build and tests succeed
- **WHEN** `xcodebuild test` runs against the renamed `RickMortyChallenge` and `RickMortyChallengeScreenshotTests` schemes
- **THEN** the build succeeds and all unit and screenshot tests pass

#### Scenario: CI references the renamed project
- **WHEN** the CI workflow runs
- **THEN** it targets `RickMortyChallenge.xcodeproj` with the renamed schemes and completes successfully
