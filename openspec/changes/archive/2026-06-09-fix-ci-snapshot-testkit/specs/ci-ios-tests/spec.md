## ADDED Requirements

### Requirement: Local Swift packages required by Xcode are versioned

The repository MUST track any local Swift package referenced by `XCLocalSwiftPackageReference` in the Xcode project so a clean checkout on CI can resolve package dependencies.

#### Scenario: SnapshotTestKit is present after checkout

- **WHEN** CI checks out the repository on a fresh runner
- **THEN** the path `Packages/SnapshotTestKit/Package.swift` exists in the workspace

#### Scenario: SPM build artifacts remain ignored

- **WHEN** a developer builds local Swift packages
- **THEN** `.build/` and `.swiftpm/` directories under `Packages/` are not committed to git

---

### Requirement: CI deployment targets match the GitHub Actions simulator matrix

Test targets executed by the **iOS Tests** workflow MUST use deployment targets less than or equal to the CI simulator OS version (currently iOS 18.4 on iPhone 16).

#### Scenario: Unit and UI tests run on CI simulator

- **WHEN** GitHub Actions runs `xcodebuild test` for the `RickMortyChallenge` scheme with destination `platform=iOS Simulator,name=iPhone 16,OS=18.4`
- **THEN** `RickMortyChallengeTests` and `RickMortyChallengeUITests` are eligible to run on that simulator without deployment-target mismatch errors

#### Scenario: Widget extension compiles with lowered project target

- **WHEN** the project-level deployment target is set to iOS 16.6
- **THEN** `CharacterWidgetExtensionExtension` declares a minimum deployment target of iOS 17.0 to support widget-specific APIs

---

### Requirement: CI resolves packages before executing tests

The **iOS Tests** workflow MUST successfully resolve Swift Package Manager dependencies for both test schemes before running test targets.

#### Scenario: Main scheme package resolution succeeds

- **WHEN** CI executes the `RickMortyChallenge` scheme test step
- **THEN** `xcodebuild` completes package graph resolution without missing local package errors

#### Scenario: Screenshot scheme package resolution succeeds

- **WHEN** CI executes the `RickMortyChallengeScreenshotTests` scheme test step
- **THEN** `SnapshotTestKit` resolves from `Packages/SnapshotTestKit` and the scheme builds successfully
