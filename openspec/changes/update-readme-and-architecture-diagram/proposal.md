## Why

The `README.md` and `RickMortyArchitecture.drawio` files are partially outdated relative to the current codebase. They reference removed files (`AppRoute.swift`, local `NetworkService`), omit newer capabilities (widget extension, App Group storage, Network SPM package, screenshot tests, CI), and the architecture diagram is dense and hard to read at a glance. Accurate documentation is essential for onboarding, technical interviews, and maintaining the project as a reference implementation.

## What Changes

- **README.md**: Full audit against the live codebase; update tech stack, features, project structure, testing, widget, and contributor sections to match reality.
- **RickMortyArchitecture.drawio**: Redesign as a simplified layer diagram — four Clean Architecture layers, key components per layer, widget extension, and external dependencies — without per-class wiring.
- Add a **Features** section to README documenting all user-facing functionality (Characters with search/detail, Locations, Episodes, Home Screen Widget).
- Fix stale references: `MainTabView` (not `ContentView`), `CharacterRoute` (not `AppRoute`), `CachedAsyncImageView` (not `AsyncCachedImage`), Network SPM (not local `Data/Network/` files).
- Document `Core/Storage/` (`AppGroupStore`, `CharacterWidgetData`) and all test targets.
- Add reference to `RickMortyArchitecture.drawio` from README.
- Update minimum deployment target to iOS 16.6 and document CI workflow.

## Capabilities

### New Capabilities

- `project-documentation`: Defines requirements for keeping `README.md` and `RickMortyArchitecture.drawio` accurate, complete, and easy to understand relative to the implemented app.

### Modified Capabilities

<!-- No app behavior changes — documentation only -->

## Impact

**Affected Clean Architecture layers**: None (no code changes). Documentation spans all layers descriptively.

**Affected files**:
- `README.md`
- `RickMortyArchitecture.drawio`

**Affected systems**: Developer onboarding, technical interview presentation, contributor setup.

## Non-goals

- Changing app behavior, architecture, or code.
- Adding new features (location/episode detail, offline mode, filters).
- Updating `docs/domain-data-standards.md` or `docs/presentation-standards.md` unless a factual inaccuracy is found.
- Adding screenshots or GIFs to README.
- Creating additional documentation files beyond README and the drawio diagram.

## Test Strategy

This is a documentation-only change. Verification does not require new unit tests or XCUITests.

- **Unit tests**: Run full suite to confirm no accidental code changes (`xcodebuild test`).
- **Simulator verification**: Not applicable — no Presentation layer code changes.
- **XCUITest**: Not applicable — no UI flow changes.
- **Documentation verification**: Manual review of README against codebase inventory; open `RickMortyArchitecture.drawio` in draw.io to confirm diagram renders and is readable at a glance.
