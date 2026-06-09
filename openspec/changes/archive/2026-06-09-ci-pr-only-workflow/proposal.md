## Why

The **iOS Tests** GitHub Actions workflow currently runs on every push to `main` as well as on pull requests, causing redundant CI runs after a PR is merged when the branch was already validated. The workflow also lacks common CI optimizations (dependency caching, concurrency control, explicit package resolution), which increases runner time and cost without adding quality signal post-merge.

## What Changes

- Restrict workflow triggers to `pull_request` only; remove the `push` trigger on `main`.
- Add GitHub Actions concurrency so in-flight runs for the same PR are cancelled when new commits are pushed.
- Add caching for Swift Package Manager artifacts and Xcode DerivedData keyed on `Package.resolved` and project hash.
- Add an explicit `xcodebuild -resolvePackageDependencies` step before test execution for clearer failure diagnostics.
- Apply minimal workflow permissions (`contents: read`) and keep existing test coverage (unit, UI, and screenshot schemes).
- Update README CI documentation to reflect PR-only execution.

## Capabilities

### New Capabilities
- `ci-ios-tests`: Define when and how the GitHub Actions iOS test workflow runs, including trigger policy, caching, concurrency, and package resolution requirements.

### Modified Capabilities
- `project-documentation`: Update README CI/CD section to state the workflow runs on pull requests only, not on pushes to `main`.
- `ui-screenshot-regression-tests`: Clarify that visual regression enforcement applies during pull request validation, not on post-merge pushes to `main`.

## Impact

- **CI/CD**: `.github/workflows/ios-tests.yml` trigger configuration, job structure, and caching strategy.
- **Documentation**: `README.md` CI/CD section updated to match new trigger policy.
- **Clean Architecture layers affected**: Testing infrastructure (cross-cutting); no Domain, Data, Core, or Presentation behavior changes.

## Non-goals

- Changing test targets, schemes, assertions, or screenshot baselines.
- Upgrading GitHub Actions runners, Xcode version, or the CI simulator matrix.
- Adding new CI jobs (lint, build-only, release pipelines, or deployment).
- Introducing branch protection rules or GitHub repository settings changes (document only; configuration is out of repo scope).

## Test Strategy

- **Workflow validation**: Open or update a pull request and confirm the **iOS Tests** workflow runs and passes.
- **Post-merge verification**: Merge (or simulate by pushing to `main`) and confirm the workflow does **not** trigger on `push` to `main`.
- **Cache effectiveness**: Inspect workflow logs on a second PR push to confirm cache restore hits for SPM/DerivedData paths.
- **Unit / UI / screenshot tests**: Existing test suites remain unchanged; CI continues to run `RickMortyChallenge` and `RickMortyChallengeScreenshotTests` schemes.
- **Simulator verification**: Not required — no app UI or Presentation layer changes.
