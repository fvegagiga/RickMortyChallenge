# Capability: CI iOS Tests

## Purpose

Defines repository and GitHub Actions requirements so iOS test workflows resolve local Swift packages, use compatible deployment targets, and run reliably on the configured simulator matrix.

## Requirements

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

Test targets executed by the **iOS Tests** workflow MUST use deployment targets less than or equal to the CI simulator OS version (currently iOS 18.5 on iPhone 16).

#### Scenario: Unit and UI tests run on CI simulator

- **WHEN** GitHub Actions runs `xcodebuild test` for the `RickMortyChallenge` scheme with destination `platform=iOS Simulator,name=iPhone 16,OS=18.5`
- **THEN** `RickMortyChallengeTests` and `RickMortyChallengeUITests` are eligible to run on that simulator without deployment-target mismatch errors

#### Scenario: Widget extension compiles with lowered project target

- **WHEN** the project-level deployment target is set to iOS 16.6
- **THEN** `CharacterWidgetExtensionExtension` declares a minimum deployment target of iOS 17.0 to support widget-specific APIs

---

### Requirement: CI resolves packages before executing tests

The **iOS Tests** workflow MUST resolve Swift Package Manager dependencies in a dedicated step before executing any `xcodebuild test` command, and MUST successfully resolve dependencies for both test schemes.

#### Scenario: Explicit package resolution step

- **WHEN** the workflow prepares the workspace for testing
- **THEN** it runs `xcodebuild -resolvePackageDependencies` for the Xcode project and fails fast if resolution errors occur

#### Scenario: Main scheme package resolution succeeds

- **WHEN** CI executes the `RickMortyChallenge` scheme test step
- **THEN** `xcodebuild` completes package graph resolution without missing local package errors

#### Scenario: Screenshot scheme package resolution succeeds

- **WHEN** CI executes the `RickMortyChallengeScreenshotTests` scheme test step
- **THEN** `SnapshotTestKit` resolves from `Packages/SnapshotTestKit` and the scheme builds successfully

---

### Requirement: CI runs on pull requests only

The **iOS Tests** GitHub Actions workflow MUST trigger exclusively on `pull_request` events and MUST NOT trigger on `push` events to any branch, including `main`.

#### Scenario: Pull request triggers CI

- **WHEN** a contributor opens or updates a pull request targeting `main`
- **THEN** the **iOS Tests** workflow runs for that pull request

#### Scenario: Merge to main does not trigger CI

- **WHEN** a pull request is merged and commits land on `main`
- **THEN** the **iOS Tests** workflow does not run as a result of that push

#### Scenario: Direct push to main does not trigger CI

- **WHEN** a commit is pushed directly to `main` without an associated pull request workflow run
- **THEN** the **iOS Tests** workflow does not run

---

### Requirement: CI cancels superseded pull request runs

The **iOS Tests** workflow MUST use GitHub Actions concurrency so that only the latest run for a given pull request executes, cancelling in-progress runs when new commits are pushed.

#### Scenario: New push cancels previous run

- **WHEN** a contributor pushes additional commits to an open pull request while a workflow run is in progress
- **THEN** the in-progress run is cancelled and a new run starts for the latest commit

---

### Requirement: CI caches Swift Package Manager and build artifacts

The **iOS Tests** workflow MUST cache Swift Package Manager and Xcode build artifacts between runs to reduce redundant dependency resolution and compilation time.

#### Scenario: Cache key reflects dependency lockfile

- **WHEN** the workflow restores or saves cache entries
- **THEN** the cache key incorporates a hash of `RickMortyChallenge.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

#### Scenario: SPM cache paths are included

- **WHEN** the workflow saves or restores cache entries
- **THEN** the cached paths include the SwiftPM global cache directory and Xcode DerivedData for the project

---

### Requirement: CI uses minimal workflow permissions

The **iOS Tests** workflow MUST declare the minimum GitHub Actions permissions required to checkout code and run tests.

#### Scenario: Read-only repository access

- **WHEN** the workflow executes on a pull request
- **THEN** it requests only `contents: read` permission at the workflow level

---

### Requirement: CI executes all test schemes on the standard simulator matrix

The **iOS Tests** workflow MUST continue to run unit, UI, and screenshot regression tests on the established GitHub Actions simulator profile without reducing test coverage.

#### Scenario: Main scheme tests run on CI

- **WHEN** the workflow executes the primary test step
- **THEN** it runs `xcodebuild test` for the `RickMortyChallenge` scheme on `platform=iOS Simulator,name=iPhone 16,OS=18.5`

#### Scenario: Screenshot scheme tests run on CI

- **WHEN** the workflow executes the screenshot regression step
- **THEN** it runs `xcodebuild test` for the `RickMortyChallengeScreenshotTests` scheme on the same simulator destination
