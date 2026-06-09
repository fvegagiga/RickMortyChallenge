## Context

The repository ships a single GitHub Actions workflow at `.github/workflows/ios-tests.yml` that runs unit, UI, and screenshot regression tests on `macos-15` with an iPhone 16 simulator (iOS 18.5). The workflow currently triggers on both `pull_request` and `push` to `main`, which duplicates validation already performed during PR review. The workflow has no caching, concurrency control, explicit package resolution, or scoped permissions.

## Goals / Non-Goals

**Goals:**
- Run **iOS Tests** only on pull requests to avoid redundant post-merge CI runs.
- Reduce workflow duration and runner cost through SPM and DerivedData caching.
- Cancel stale in-flight runs when a PR receives new commits.
- Improve failure diagnostics with an explicit package-resolution step.
- Follow GitHub Actions security best practices with minimal permissions.
- Keep existing test coverage (both schemes, same simulator destination).

**Non-Goals:**
- Changing test targets, schemes, baselines, or deployment targets.
- Adding new workflows (lint, release, nightly builds).
- Modifying branch protection or repository settings outside the workflow file.
- Splitting unit/UI and screenshot tests into separate jobs (single job keeps simulator boot cost low for this project size).

## Decisions

1. **Pull-request-only trigger**
   - Decision: Remove the `push: branches: [main]` trigger; keep only `pull_request`.
   - Rationale: PR validation is the quality gate; re-running the full suite on merge adds no new signal and doubles macOS runner minutes.
   - Alternative considered: Keep `push` to `main` for a lightweight smoke job. Rejected because the user explicitly requested PR-only execution and the full test suite is expensive on macOS runners.

2. **Concurrency with cancel-in-progress**
   - Decision: Add `concurrency: group: ios-tests-${{ github.event.pull_request.number }}, cancel-in-progress: true`.
   - Rationale: Standard pattern for PR workflows; avoids wasting runner time on outdated commits.
   - Alternative considered: `concurrency` keyed on `github.ref`. Rejected because PR number groups all runs for the same review thread more reliably.

3. **Dual-path caching (SPM + DerivedData)**
   - Decision: Use `actions/cache@v4` with two cache entries:
     - SPM: `~/Library/Caches/org.swift.swiftpm` keyed by `hashFiles('**/Package.resolved')`.
     - DerivedData: `~/Library/Developer/Xcode/DerivedData` keyed by `hashFiles('**/Package.resolved')` plus project file hash.
   - Rationale: Common iOS CI pattern; `Package.resolved` invalidates cache when remote dependencies change; project hash covers local package and pbxproj edits.
   - Alternative considered: Third-party `actions/cache-xcode` action. Rejected to minimize external dependencies for a single workflow.

4. **Explicit package resolution step**
   - Decision: Run `xcodebuild -resolvePackageDependencies -project RickMortyChallenge.xcodeproj -scheme RickMortyChallenge` before test steps.
   - Rationale: Surfaces SPM resolution failures independently from test compilation; aligns with the open question from the prior CI fix change.
   - Alternative considered: Rely on implicit resolution inside `xcodebuild test`. Rejected because failures are harder to diagnose.

5. **Minimal permissions**
   - Decision: Set top-level `permissions: contents: read`.
   - Rationale: Workflow only checks out code and runs tests; no packages, deployments, or PR writes needed.
   - Alternative considered: Default GITHUB_TOKEN permissions. Rejected because explicit least-privilege is a GitHub-recommended practice.

6. **Preserve single-job structure with shared DerivedData**
   - Decision: Keep one `tests` job running both schemes sequentially, sharing the same DerivedData cache within the job.
   - Rationale: Booting the simulator and warming DerivedData once is cheaper than parallel jobs for this project's test duration.
   - Alternative considered: Matrix or parallel jobs per scheme. Rejected due to doubled simulator startup and cache complexity.

7. **Document PR-only policy in README**
   - Decision: Update the CI/CD section to state pull-request-only triggers and mention caching/concurrency at a high level.
   - Rationale: Keeps contributor documentation aligned with workflow behavior per `project-documentation` spec.

## Risks / Trade-offs

- **[Risk] Direct pushes to `main` bypass CI entirely** → **Mitigation:** Rely on branch protection requiring PR checks before merge; document that all changes should go through PRs.
- **[Risk] Stale DerivedData cache causes build failures after major Xcode/project changes** → **Mitigation:** Cache key includes `Package.resolved` and `project.pbxproj` hashes; GitHub cache eviction also limits staleness.
- **[Risk] First PR run after cache miss remains slow** → **Mitigation:** Expected behavior; subsequent runs benefit from warm cache.
- **[Risk] `pull_request` event does not run for fork PRs without `pull_request_target` (not needed here)** → **Mitigation:** Standard `pull_request` trigger works for same-repo branches; no secrets are exposed to fork workflows in this setup.

## Migration Plan

1. Update `.github/workflows/ios-tests.yml` with new triggers, concurrency, permissions, cache steps, and package resolution.
2. Update `README.md` CI/CD section to reflect PR-only policy.
3. Open a pull request and confirm the workflow runs and passes.
4. Merge and verify no workflow run is triggered by the merge push.
5. Rollback: restore previous workflow YAML from git history if unexpected CI gaps appear.

## Open Questions

- Should branch protection rules be documented in README as a recommended repository setting (outside repo scope)?
- Should a future change split screenshot tests into a separate job once test duration grows significantly?
