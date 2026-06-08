## Why

The app currently has no visual regression safety net, so UI changes can ship with unnoticed layout or style regressions. We need a dedicated screenshot test target now to protect all app screens as the product grows.

## What Changes

- Add a new test target named `RickMortyPersistImageScreenshotTests`.
- Configure the target to run deterministic screenshot assertions for every app screen.
- Add screenshot test suites and baseline references for all current screens and major UI states.
- Integrate screenshot tests into local simulator verification and CI test execution.

## Capabilities

### New Capabilities
- `ui-screenshot-regression-tests`: Add first-class screenshot regression coverage for all app screens through a dedicated screenshot test target.

### Modified Capabilities
- None.

## Impact

- **Presentation layer**: All SwiftUI screens become covered by visual regression snapshots, including navigation and common UI states.
- **Testing layer**: A new screenshot test target and supporting test infrastructure are added to the Xcode project.
- **Build and CI**: Test execution workflows include screenshot validation on a stable simulator/device profile.
- **Dependencies**: A snapshot testing dependency may be added if the existing stack does not already provide one.

## Non-goals

- Redesigning existing screens or changing production UX behavior.
- Replacing unit tests, integration tests, or XCUITests with screenshot tests.
- Adding screenshot coverage for features not yet shipped in the app.

## Test Strategy

- Unit tests remain mandatory for any helper or mapping logic introduced for screenshot setup.
- Simulator verification runs screenshot suites on a fixed simulator model, OS version, locale, and appearance.
- XCUITest validation remains in place for interaction flows; screenshot tests complement visual fidelity checks.
