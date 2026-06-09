## Context

The repository includes a local Swift package at `Packages/SnapshotTestKit` referenced by `RickMortyChallengeScreenshotTests` through an `XCLocalSwiftPackageReference` in `RickMortyChallenge.xcodeproj`. The `.gitignore` file excludes the entire `Packages/` directory, so a fresh CI checkout cannot resolve the package and `xcodebuild test` fails with exit code 74 before any tests run.

Additionally, project-level and unit-test deployment targets were set to iOS 26.5 (likely from a local Xcode beta default), while GitHub Actions runs on `macos-15` with Xcode 16.4 and an iPhone 16 simulator on iOS 18.4. The widget extension uses iOS 17+ APIs (`containerBackground`, widget `#Preview`) and requires an explicit minimum deployment target when the project-level target is lowered.

## Goals / Non-Goals

**Goals:**
- Ensure `Packages/SnapshotTestKit` is tracked in git while SPM build artifacts remain ignored.
- Align deployment targets so all CI schemes build and run on the GitHub Actions simulator profile.
- Restore a green **iOS Tests** workflow for both `RickMortyChallenge` and `RickMortyChallengeScreenshotTests` schemes.

**Non-Goals:**
- Changing screenshot baselines, test assertions, or screenshot coverage.
- Replacing `SnapshotTestKit` with a remote package dependency.
- Upgrading GitHub Actions runners or the CI simulator matrix.

## Decisions

1. **Selective `.gitignore` exception for the local package**
   - Decision: Replace blanket `Packages/` ignore with `Packages/*` plus explicit allow rules for `Packages/SnapshotTestKit/`, while continuing to ignore `Packages/**/.build/` and `Packages/**/.swiftpm/`.
   - Rationale: Keeps the local package versioned without committing transient SPM artifacts.
   - Alternative considered: Move `SnapshotTestKit` to a remote Git dependency. Rejected to avoid extra repository management for a small, project-specific helper.

2. **Commit package sources, not build outputs**
   - Decision: Track only `Package.swift` and `Sources/SnapshotTestKit/SnapshotTestKit.swift`.
   - Rationale: Matches standard SPM layout and keeps the repository lean.
   - Alternative considered: Vendor the helper directly into the screenshot test target. Rejected because the project already references a local package in the Xcode project.

3. **Deployment target alignment for CI compatibility**
   - Decision: Set project-level and `RickMortyChallengeTests` deployment target to iOS 16.6 (matching the app target); set `CharacterWidgetExtensionExtension` to iOS 17.0 explicitly.
   - Rationale: CI uses iOS 18.4 simulators; iOS 26.5 is unavailable on GitHub Actions. Widget APIs require iOS 17+ regardless of project-level default.
   - Alternative considered: Upgrade CI to a beta Xcode with iOS 26 simulators. Rejected because standard `macos-15` runners do not provide that runtime reliably.

4. **No CI workflow changes in this increment**
   - Decision: Keep existing `.github/workflows/ios-tests.yml` destination (`iPhone 16`, `OS=18.4`) unchanged.
   - Rationale: The workflow is correct; the repository configuration was the blocker.
   - Alternative considered: Pin a different simulator in CI. Rejected unless deployment-target fixes prove insufficient.

## Risks / Trade-offs

- **[Risk] Future local packages under `Packages/` are accidentally ignored** → **Mitigation:** Document the allow-list pattern in README or technical docs when adding new local packages.
- **[Risk] Widget builds fail if project-level target is lowered without an extension override** → **Mitigation:** Set `IPHONEOS_DEPLOYMENT_TARGET = 17.0` on the widget extension target explicitly.
- **[Risk] CI passes locally but fails on GitHub due to environment drift** → **Mitigation:** Run `xcodebuild test` locally with the same destination string as CI before merging.

## Migration Plan

1. Update `.gitignore` with selective `Packages/SnapshotTestKit` rules.
2. Add `Packages/SnapshotTestKit` source files to git.
3. Adjust deployment targets in `project.pbxproj`.
4. Verify `build-for-testing` and `xcodebuild test` locally using the CI destination.
5. Push branch and confirm GitHub Actions **iOS Tests** workflow passes.
6. Rollback: revert the commit and temporarily disable screenshot tests in CI if an unexpected regression appears.

## Open Questions

- Should README explicitly document the versioned local `SnapshotTestKit` package and the `.gitignore` exception pattern?
- Should a lightweight CI smoke step run `xcodebuild -resolvePackageDependencies` before tests for clearer failure messages?
