## MODIFIED Requirements

### Requirement: Dedicated screenshot test target
The project MUST define a standalone test target named `RickMortyChallengeScreenshotTests` that builds and runs independently from existing unit and XCUITest targets.

#### Scenario: Target is available in the project
- **WHEN** developers inspect the Xcode project test targets
- **THEN** a target named `RickMortyChallengeScreenshotTests` is present and runnable
