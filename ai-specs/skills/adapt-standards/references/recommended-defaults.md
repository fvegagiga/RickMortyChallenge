# Recommended Defaults (New Projects)

These are the opinionated defaults the `adapt-standards` skill applies when starting a **new** iOS
project from scratch. They favor modern Swift/SwiftUI and the simplest setup that still scales.
Override any of them when the project has a concrete reason to; record the final choice in
`docs/project-profile.md`.

## Platform & Tooling

- **Minimum deployment target**: iOS 17+. This unlocks the Observation framework and SwiftData.
- **Swift language mode**: Swift 6 (or, if a dependency blocks it, Swift 5 with *Strict Concurrency
  Checking = Complete*). Data races become compile-time errors.
- **Module layout**: single app target with folder-based Clean Architecture layers. Promote to SPM
  modules only when build times, team size, or boundary enforcement demand it
  (see `docs/advanced-topics.md`).
- **Package management**: Swift Package Manager.

## Architecture Roles

- **State management**: `@Observable` (Observation framework). The view owns the ViewModel with
  `@State`; shared instances are injected with `@Environment`. Use `ObservableObject` only when the
  deployment target is below iOS 17.
- **Dependency injection**: constructor injection of protocols, wired in a single hand-written
  composition root. Reach for a DI library only if the graph becomes large; never use global
  singletons or service locators buried inside types.
- **Navigation**: typed `Hashable` routes driven through `NavigationStack(path:)`, centralized in a
  lightweight router object. Avoid inline `NavigationLink(destination:)` and never navigate from a
  ViewModel.
- **Design tokens**: a single token namespace for colors, spacing, and typography
  (e.g. `Color.DS.*`, `DSSpacing`, `DSTypography`). No inline literals in views.

## Connectivity & Data

- **Networking**: `URLSession` behind a `NetworkServiceProtocol`. No third-party HTTP client unless
  required. Add a decorator for retry/auth/logging only when the need is real.
- **Endpoint catalog**: a typed `APIEndpoint` enum; no raw URL strings in repositories.
- **Pagination**: a `PagedResult<T>` value type for any paginated or large collection.
- **Remote images**: a cached image view backed by a memory + disk cache, used instead of
  `AsyncImage` when caching matters. Skip entirely for asset-only UIs.
- **Local persistence**: none by default. When needed: **SwiftData** for a structured model graph
  (iOS 17+), **Keychain** for secrets/tokens, `UserDefaults`/`@AppStorage` for small preferences.
  Persistence types live in the Data layer behind the same repository protocols.

## Testing

- **Unit/integration**: Swift Testing (`@Test`, `#expect`, `@Suite`).
- **UI / end-to-end**: XCUITest.
- **Coverage**: 90%+ across Domain and Data layers; ViewModels need happy-path + error-path tests.
- **Test doubles**: `Mock<Role>` types conforming to the protocol, plus a `MockDataFactory` for data.

## Cross-cutting principles (never defaulted away)

These always apply regardless of the choices above:

- Clean Architecture with the dependency rule (Domain depends on nothing outward).
- Full type safety; `Sendable` across isolation boundaries.
- `async/await` for all asynchronous work; no completion handlers.
- `@MainActor` ViewModels; typed error enums; user-friendly error mapping.
- English-only technical artifacts; clear, intent-revealing naming.
