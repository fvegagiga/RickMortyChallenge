## MODIFIED Requirements

### Requirement: README reflects current tech stack and dependencies

The `README.md` SHALL accurately document the technology stack, including the Network SPM package, iOS 16.6 minimum deployment, App Group identifier, all test targets, and CI workflow.

#### Scenario: Network SPM is documented

- **WHEN** a contributor reads the Tech Stack or Dependencies section
- **THEN** networking is described as the external `Network` SPM package (with `RetryingNetworkService` wired in `DIContainer`), not as local files under `Data/Network/`

#### Scenario: Test targets are documented

- **WHEN** a contributor reads the Testing Strategy section
- **THEN** all four test-related targets are listed: `RickMortyChallengeTests`, `RickMortyChallengeUITests`, `RickMortyChallengeScreenshotTests`, and widget-related unit tests under `RickMortyChallengeTests/Widget/` and `RickMortyChallengeTests/Storage/`

#### Scenario: CI trigger policy is documented

- **WHEN** a contributor reads the CI/CD section of `README.md`
- **THEN** it states the **iOS Tests** workflow runs on pull requests only and does not run on pushes to `main` after merge
