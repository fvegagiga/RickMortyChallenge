## ADDED Requirements

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

### Requirement: CI resolves packages before running tests

The **iOS Tests** workflow MUST resolve Swift Package Manager dependencies in a dedicated step before executing any `xcodebuild test` command.

#### Scenario: Explicit package resolution step

- **WHEN** the workflow prepares the workspace for testing
- **THEN** it runs `xcodebuild -resolvePackageDependencies` for the Xcode project and fails fast if resolution errors occur

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
