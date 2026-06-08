## Context

The app has SwiftUI presentation screens but currently lacks screenshot-based regression checks. Existing automated quality gates cover behavior (unit tests and XCUITests) but not pixel-level visual drift. This change introduces a dedicated screenshot target that validates all shipped screens under deterministic simulator conditions and keeps visual baselines versioned with the project.

## Goals / Non-Goals

**Goals:**
- Add a new `RickMortyPersistImageScreenshotTests` target wired into the current Xcode workspace.
- Provide deterministic screenshot execution (device, OS runtime, locale, color scheme, content size category).
- Cover all app screens and key UI states with maintainable snapshot test cases.
- Integrate screenshot verification into local and CI test workflows without weakening existing test suites.

**Non-Goals:**
- Redesigning UI components or changing product navigation.
- Replacing interaction-level XCUITests or business-logic unit tests.
- Adding visual coverage for unreleased or prototype screens.

## Decisions

1. **Dedicated target for isolation**
   - Decision: Create `RickMortyPersistImageScreenshotTests` as a separate test target.
   - Rationale: Isolates snapshot dependencies/configuration and prevents coupling with existing unit/UI test targets.
   - Alternative considered: Add screenshot tests to existing UI test target. Rejected due to mixed responsibilities and harder baseline management.

2. **Deterministic rendering harness**
   - Decision: Standardize simulator profile and test environment inputs (appearance, locale, dynamic type, optional animation disabling).
   - Rationale: Reduces flaky diffs and keeps baselines stable across machines and CI.
   - Alternative considered: Accept default runtime configuration. Rejected because it creates non-actionable snapshot noise.

3. **Screen-first coverage map**
   - Decision: Define one test suite per screen/flow entry point and include major visual states (loading, content, empty, error when applicable).
   - Rationale: Keeps tests discoverable and ensures complete coverage for all existing app screens.
   - Alternative considered: Single monolithic test file. Rejected because it scales poorly and complicates failures triage.

4. **CI regression gate**
   - Decision: Run screenshot tests in CI using the same simulator matrix as local verification.
   - Rationale: Prevents visual regressions from merging unnoticed.
   - Alternative considered: Local-only execution. Rejected because it relies on manual discipline.

## Risks / Trade-offs

- **[Risk] Baseline churn from tiny rendering differences** -> **Mitigation:** Pin simulator/device and environment; document baseline refresh workflow.
- **[Risk] Slower test pipeline** -> **Mitigation:** Keep snapshots scoped to representative states and parallelize test execution where available.
- **[Risk] Brittle data-dependent views** -> **Mitigation:** Use deterministic fixtures/mocks for screen data setup in screenshot tests.

## Migration Plan

1. Add target and dependencies in Xcode project.
2. Add screenshot test infrastructure and deterministic test harness.
3. Implement per-screen snapshot test suites with fixtures.
4. Generate and commit first trusted baselines.
5. Enable execution in CI and local verification scripts.
6. If rollback is needed, disable the new target from CI and remove the test target changes in a dedicated revert commit.

## Open Questions

- Which simulator/device pair is the canonical baseline target for this repository?
- Which snapshot framework is preferred by the team if no dependency currently exists?
- Should dark mode snapshots be mandatory for all screens in the first increment or phased in after light mode parity?
