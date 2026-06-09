## Why

The project is currently named `RickMortyPersistImage`, a name inherited from an early
prototype focused on image persistence. The product has since grown into a full Rick and
Morty API client (characters, episodes, locations, widget). The name no longer reflects the
project and creates confusion across the codebase, build configuration, and documentation.
Renaming everything to `RickMortyChallenge` establishes a single, accurate project identity.

## What Changes

- **BREAKING**: Rename the Xcode project, app target, and all test targets from
  `RickMortyPersistImage*` to `RickMortyChallenge*`.
- Rename the app source module/group and the directories
  `RickMortyPersistImage/`, `RickMortyPersistImageTests/`, `RickMortyPersistImageUITests/`,
  `RickMortyPersistImageScreenshotTests/`, and `RickMortyPersistImage.xcodeproj/`.
- **BREAKING**: Update product bundle identifiers
  (`com.fvg0902iosdev.RickMortyPersistImage*` → `com.fvg0902iosdev.RickMortyChallenge*`).
- **BREAKING**: Update the App Group identifier
  (`group.com.fvg0902iosdev.RickMortyPersistImage.widget` →
  `group.com.fvg0902iosdev.RickMortyChallenge.widget`) in entitlements and `AppGroupStore`.
- Rename the `RickMortyPersistImageApp` SwiftUI `App` struct (and its file) and update every
  `@testable import RickMortyPersistImage` to `@testable import RickMortyChallenge`.
- Rename the test plan (`RickMortyPersistImageTests.xctestplan`) and all shared schemes,
  updating their internal references (`BlueprintName`, `BuildableName`, `ReferencedContainer`,
  `TEST_HOST`, `TEST_TARGET_NAME`, container paths).
- Update the CI workflow (`.github/workflows/ios-tests.yml`) project/scheme references.
- Update live documentation that references the old name (`README.md`, `docs/*`,
  current `openspec/specs/*`, `ai-specs/skills/*`) and the architecture diagram
  (`RickMortyArchitecture.drawio`).
- Verify the renamed project builds and all tests (unit + screenshot) pass.

## Capabilities

### New Capabilities
- `project-identity`: Defines the canonical project name `RickMortyChallenge` as the single
  source of truth for the Xcode project, targets, source module, bundle identifiers, and
  App Group identifier, with a requirement that no live artifact references the legacy name.

### Modified Capabilities
- `ui-screenshot-regression-tests`: The dedicated screenshot test target requirement changes
  its target name from `RickMortyPersistImageScreenshotTests` to
  `RickMortyChallengeScreenshotTests`.

## Impact

- **Affected layers**: Cross-cutting. Touches build configuration (Xcode project, schemes,
  test plan, entitlements), the Presentation layer entry point (`App` struct), the Core layer
  (`AppGroupStore` App Group identifier), all test targets (module imports), CI, and docs.
- **Affected systems**: Code signing / provisioning (new bundle identifiers and App Group must
  be available for the signing profile), the Widget extension (shared App Group data), and CI.
- **Dependencies**: No third-party dependency changes; Swift Package references are unaffected.

## Non-goals

- Renaming the Widget extension target/identifier
  (`CharacterWidgetExtension`, `com.fvg0902iosdev.RickMortyPersistImage.CharacterWidgetExtension`)
  beyond the embedded project-name segment required for consistency — the extension's own
  feature name (`CharacterWidgetExtension`) is preserved.
- Rewriting archived OpenSpec artifacts under `openspec/changes/archive/**` and their historical
  reports. These are point-in-time records and MUST remain unchanged to preserve project history.
- Any behavioral, UI, or API change. This is a pure rename; runtime behavior is unchanged.

## Test Strategy

- **Unit tests**: Run the `RickMortyChallenge` scheme test action (renamed unit test target)
  via `xcodebuild test` and confirm all existing tests pass unchanged.
- **Screenshot tests**: Run the `RickMortyChallengeScreenshotTests` scheme and confirm baselines
  still match (rename must not alter rendered output).
- **Simulator verification**: Launch the renamed app on the simulator and verify the widget
  App Group data sharing still works with the new App Group identifier.
- **XCUITest**: Run the renamed UI test target to confirm app launch and navigation are intact.
