## Why

The GitHub Actions **iOS Tests** workflow fails immediately after pushing to the remote repository because the local Swift package `Packages/SnapshotTestKit` is excluded by `.gitignore`, so CI cannot resolve screenshot test dependencies. A secondary mismatch between test deployment targets (iOS 26.5 from local Xcode beta) and the CI simulator profile (iPhone 16, iOS 18.4) would block test execution even after the package is available.

## What Changes

- Update `.gitignore` to version-control `Packages/SnapshotTestKit/` while still ignoring SPM build artifacts (`.build/`, `.swiftpm/`).
- Commit the local `SnapshotTestKit` package sources (`Package.swift`, `SnapshotTestKit.swift`) required by `RickMortyChallengeScreenshotTests`.
- Align project and test target deployment targets with CI-compatible values (project/tests at iOS 16.6, widget extension at iOS 17.0 for widget APIs).
- Verify both CI workflow steps (`RickMortyChallenge` and `RickMortyChallengeScreenshotTests` schemes) build and run on the GitHub Actions simulator profile.

## Capabilities

### New Capabilities
- `ci-ios-tests`: Define repository and CI requirements so iOS test workflows resolve local Swift packages and run on the GitHub Actions simulator matrix without deployment-target mismatches.

### Modified Capabilities
- `ui-screenshot-regression-tests`: Require the `SnapshotTestKit` local package to be tracked in source control so CI can resolve screenshot test dependencies.

## Impact

- **Testing layer**: `SnapshotTestKit` becomes a first-class, versioned local Swift package in the repository.
- **Build configuration**: Deployment targets for project-level settings, unit/UI test targets, and widget extension are aligned with CI and platform API requirements.
- **CI/CD**: GitHub Actions `ios-tests.yml` can resolve package dependencies and execute unit, UI, and screenshot test schemes on `macos-15` with iOS 18.4.
- **Clean Architecture layers affected**: Testing infrastructure (cross-cutting); no Domain, Data, or Presentation behavior changes.

## Non-goals

- Changing screenshot test assertions, baselines, or visual coverage scope.
- Modifying app features, navigation, or widget UI behavior.
- Upgrading the GitHub Actions runner, Xcode version, or CI simulator matrix beyond what is already configured.
- Replacing the local `SnapshotTestKit` package with a remote dependency.

## Test Strategy

- **Unit tests**: Run `RickMortyChallengeTests` via `xcodebuild test` on iPhone 16 (iOS 18.4) to confirm deployment-target alignment does not break compilation or execution.
- **Screenshot tests**: Run `RickMortyChallengeScreenshotTests` scheme to confirm `SnapshotTestKit` resolves and builds in a clean checkout.
- **XCUITests**: Run `RickMortyChallengeUITests` as part of the main scheme to confirm CI parity.
- **CI verification**: Push changes and confirm the **iOS Tests** workflow passes both workflow steps on GitHub Actions.
- **Simulator verification**: Not required — no Presentation layer UI changes; build-for-testing validation is sufficient.
