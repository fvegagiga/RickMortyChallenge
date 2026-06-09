# Capability: UI Screenshot Regression Tests

## Purpose

Defines a deterministic screenshot regression test suite for the app's primary SwiftUI screens, including baseline management and CI enforcement for visual changes.

## Requirements

### Requirement: Dedicated screenshot test target
The project MUST define a standalone test target named `RickMortyChallengeScreenshotTests` that builds and runs independently from existing unit and XCUITest targets.

#### Scenario: Target is available in the project
- **WHEN** developers inspect the Xcode project test targets
- **THEN** a target named `RickMortyChallengeScreenshotTests` is present and runnable

---

### Requirement: Full screen screenshot coverage
The screenshot test suite MUST include assertions for every production app screen and MUST capture at least one representative visual state per screen.

#### Scenario: Coverage includes all screens
- **WHEN** screenshot tests are enumerated
- **THEN** each app screen has an associated screenshot test case

#### Scenario: Baselines capture visible UI
- **WHEN** approved screenshot baselines are generated
- **THEN** each baseline contains the rendered SwiftUI screen content and is not a blank image

---

### Requirement: Deterministic screenshot execution
Screenshot tests MUST run under deterministic rendering conditions including fixed simulator profile, locale, and interface style to minimize non-functional diffs.

#### Scenario: Stable environment is enforced
- **WHEN** screenshot tests execute locally or in CI
- **THEN** they use the same predefined simulator and rendering configuration

#### Scenario: Baselines are not test bundle resources
- **WHEN** the screenshot test target is built
- **THEN** approved baseline PNG files are kept in source control for comparison and are not copied into the test bundle as runtime resources

#### Scenario: Baselines are visible in Xcode
- **WHEN** developers inspect the screenshot test folder in Xcode
- **THEN** approved baseline PNG files are visible under a `snapshots` directory without being target resources

#### Scenario: Host app does not load production content
- **WHEN** screenshot tests execute inside the host application
- **THEN** the production app bootstrap is disabled so network-backed screens do not run in parallel with the screenshot harness

---

### Requirement: Visual regression detection in CI
The CI workflow MUST execute the screenshot test target during pull request validation and MUST fail the pipeline when screenshot comparisons detect visual regressions. The workflow MUST NOT rely on post-merge pushes to `main` for visual regression enforcement.

#### Scenario: CI blocks regressions on pull request
- **WHEN** a pull request introduces an unexpected visual diff
- **THEN** CI reports screenshot test failures and prevents merge until resolved

#### Scenario: Post-merge push does not re-run screenshot tests
- **WHEN** a pull request with passing screenshot tests is merged to `main`
- **THEN** the merge push does not trigger a new CI run that re-executes screenshot tests

---

### Requirement: Baseline update workflow
The repository MUST document and support a repeatable workflow to refresh approved screenshot baselines when intentional UI changes occur.

#### Scenario: Intentional UI change updates baselines
- **WHEN** a developer intentionally modifies screen UI
- **THEN** they can regenerate and commit updated baselines through the documented process

---

### Requirement: SnapshotTestKit local package is versioned for CI

The screenshot regression test infrastructure MUST include the `SnapshotTestKit` local Swift package in source control so CI and fresh clones can build `RickMortyChallengeScreenshotTests`.

#### Scenario: Package sources are tracked in git

- **WHEN** a contributor clones the repository
- **THEN** `Packages/SnapshotTestKit/Sources/SnapshotTestKit/SnapshotTestKit.swift` is available without local-only setup steps

#### Scenario: Screenshot tests resolve SnapshotTestKit in CI

- **WHEN** the **iOS Tests** workflow runs the `RickMortyChallengeScreenshotTests` scheme
- **THEN** Xcode resolves `SnapshotTestKit` from the local path `Packages/SnapshotTestKit` without a "folder doesn't exist" error
