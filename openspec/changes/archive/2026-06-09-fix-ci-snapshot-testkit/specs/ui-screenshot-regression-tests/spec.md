## ADDED Requirements

### Requirement: SnapshotTestKit local package is versioned for CI

The screenshot regression test infrastructure MUST include the `SnapshotTestKit` local Swift package in source control so CI and fresh clones can build `RickMortyChallengeScreenshotTests`.

#### Scenario: Package sources are tracked in git

- **WHEN** a contributor clones the repository
- **THEN** `Packages/SnapshotTestKit/Sources/SnapshotTestKit/SnapshotTestKit.swift` is available without local-only setup steps

#### Scenario: Screenshot tests resolve SnapshotTestKit in CI

- **WHEN** the **iOS Tests** workflow runs the `RickMortyChallengeScreenshotTests` scheme
- **THEN** Xcode resolves `SnapshotTestKit` from the local path `Packages/SnapshotTestKit` without a "folder doesn't exist" error
