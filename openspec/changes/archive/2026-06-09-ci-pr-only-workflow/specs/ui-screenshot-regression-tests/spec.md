## MODIFIED Requirements

### Requirement: Visual regression detection in CI

The CI workflow MUST execute the screenshot test target during pull request validation and MUST fail the pipeline when screenshot comparisons detect visual regressions. The workflow MUST NOT rely on post-merge pushes to `main` for visual regression enforcement.

#### Scenario: CI blocks regressions on pull request

- **WHEN** a pull request introduces an unexpected visual diff
- **THEN** CI reports screenshot test failures and prevents merge until resolved

#### Scenario: Post-merge push does not re-run screenshot tests

- **WHEN** a pull request with passing screenshot tests is merged to `main`
- **THEN** the merge push does not trigger a new CI run that re-executes screenshot tests
