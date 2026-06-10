---
description: Project-specific instantiation of the generic iOS standards. Records the concrete choices (state management, DI, networking, navigation, persistence, design tokens, deployment target, test framework) that the generic docs reference as "roles". Filled in by the adapt-standards skill.
globs:
alwaysApply: true
---

# Project Profile

This file is the **single source of truth for this project's concrete technical choices**. The
generic standards in `docs/domain-data-standards.md`, `docs/presentation-standards.md`, and
`docs/advanced-topics.md` describe *principles and roles*; this file records which concrete
technology, pattern, and naming fills each role **for this specific project**.

> How this file is produced: run the `adapt-standards` skill when importing the standards into a
> project. For an **existing** codebase it scans the code and fills in what is actually used. For a
> **new** project it applies the recommended defaults (see
> `ai-specs/skills/adapt-standards/references/recommended-defaults.md`) after a short questionnaire.
> Until it is filled in, the values below read `TBD` and the recommended default is shown for
> reference.

## How to read the "Status" column

- **Decided** — the choice is fixed; agents and standards must follow it.
- **TBD** — not yet decided; the recommended default applies provisionally.
- **N/A** — the role does not apply to this project (e.g. no networking in an offline app). When a
  role is N/A, the corresponding sections of the generic standards are skipped.

Qualifiers may be appended in parentheses to record confidence or maturity without leaving an axis
ambiguous:

- **Decided (inferred)** — concluded indirectly (e.g. a dependency `import`) rather than proven by a
  build setting or lockfile; revisit if it matters.
- **Decided (minimal)** — the principle is adopted but the formal artifact is not yet present
  (e.g. constructor injection in use but no composition-root type yet; a bare `NavigationStack`
  with no router). Note the intended end state in the cell.

---

## 1. Platform & Tooling

| Axis | This project | Recommended default | Status |
|---|---|---|---|
| Minimum deployment target | iOS 17.0 (all targets) | iOS 17+ | Decided |
| Swift language mode | Swift 5.0, `SWIFT_STRICT_CONCURRENCY = targeted` | Swift 6 (or Strict Concurrency = Complete) | Decided |
| Module layout | Single app target (`RickMortyChallenge`) with folder-based Clean Architecture layers + `CharacterWidgetExtension` + local SPM package `Packages/SnapshotTestKit` | Single app target (folder-based layers) | Decided |
| Package management | Swift Package Manager — remote dependency `Network` 1.0.2 (`fvegagiga/Network`) | Swift Package Manager | Decided |

## 2. Architecture Roles

| Role | This project (concrete type / approach) | Recommended default | Status |
|---|---|---|---|
| State management | `ObservableObject` + `@Published` (ViewModels, `DIContainer`, `AppRouter`) | `@Observable` (Observation framework) | Decided |
| Dependency injection / composition root | Constructor injection + `DIContainer` wired at app startup, passed via `@EnvironmentObject` | Constructor injection + a hand-written container | Decided |
| Navigation strategy | Typed `CharacterRoute` + `NavigationStack(path:)` via `AppRouter` (`NavigationPath`) | Typed routes + `NavigationStack` via a lightweight router | Decided |
| Design-token namespace | `Color.DS.*` (`DSColors.swift`), `DSSpacing`, `DSTypography` | `Color.DS.*` / `DSSpacing` / `DSTypography` | Decided |

## 3. Connectivity & Data

| Role | This project | Recommended default | Status |
|---|---|---|---|
| App connectivity | Remote REST API (`https://rickandmortyapi.com/api`) | Decide: remote API / local-only / hybrid | Decided |
| Networking abstraction | SPM `Network` package — `NetworkServiceProtocol`, `NetworkService` | `URLSession` behind a `NetworkServiceProtocol` | Decided |
| Endpoint catalog | `APIEndpoint` enum conforming to `Endpoint` | Typed `APIEndpoint` enum | Decided |
| Networking decorators (retry/auth/logging) | `RetryingNetworkService` wrapping `NetworkService` in `DIContainer` | Add only when needed | Decided |
| Pagination | `PagedResult<T>` for characters, locations, and episodes | `PagedResult<T>` when endpoints paginate | Decided |
| Remote image caching | `CachedAsyncImageView` + `ImageCacheManager` / `ImageCacheManagerProtocol` | A cached image view + image cache, when loading remote images | Decided |
| Local persistence | `AppGroupStore` (`UserDefaults` app group + `FileManager` widget image cache) — widget extension data sharing only; no SwiftData/Core Data/Keychain | None unless required (SwiftData for iOS 17+, Keychain for secrets) | Decided (minimal) |

## 4. Testing

| Role | This project | Recommended default | Status |
|---|---|---|---|
| Unit test framework | Swift Testing (`@Test`, `#expect`, `@Suite`) in `RickMortyChallengeTests` | Swift Testing | Decided |
| UI test framework | XCUITest (`RickMortyChallengeUITests`) + screenshot regression (`RickMortyChallengeScreenshotTests` via local `SnapshotTestKit`) | XCUITest | Decided |
| Coverage target | 90%+ line coverage across Domain and Data layers (enforced in CI) | 90%+ across Domain and Data layers | Decided |

## 5. Concrete Type Names (glossary)

Record the **actual** names this project uses for each role, so agents and contributors use the
real symbols instead of the illustrative examples in the generic docs.

| Role | Illustrative example in generic docs | This project's actual name |
|---|---|---|
| Composition root | `DIContainer` | `DIContainer` |
| Networking protocol | `NetworkServiceProtocol` | `NetworkServiceProtocol` (from `Network` SPM package) |
| Endpoint catalog | `APIEndpoint` | `APIEndpoint` |
| Networking decorator | `RetryingNetworkService` | `RetryingNetworkService` (from `Network` SPM package) |
| Navigation router | `AppRouter` | `AppRouter` |
| Navigation route | `<Feature>Route` | `CharacterRoute` |
| Paginated result | `PagedResult<T>` | `PagedResult<T>` |
| Screen state enum | `ViewState<T>` | `ViewState<T>` |
| Cached image view | `CachedAsyncImageView` | `CachedAsyncImageView` |
| Image cache | `ImageCacheManager` | `ImageCacheManager` / `ImageCacheManagerProtocol` |
| Widget data store | — | `AppGroupStore` / `AppGroupStoreProtocol` |
| Design tokens | `Color.DS.*`, `DSSpacing`, `DSTypography` | `Color.DS.*`, `DSSpacing`, `DSTypography` |
| Domain entities | `<Entity>Entity` | `CharacterEntity`, `LocationEntity`, `EpisodeEntity` |
| Test doubles | `Mock<Role>`, `MockDataFactory` | `MockNetworkService`, `MockCharacterRepository`, `MockDataFactory`, etc. |

## 6. Domain Context

Short description of the app's domain, primary entities, and (if applicable) the API it consumes.
Keep this aligned with `docs/data-model.md` and `docs/api-spec.yml` when those exist.

- **App purpose**: Browse Rick and Morty characters, locations, and episodes from the public REST
  API; includes a home-screen widget for cycling through characters and deep-linking into the app.
- **Primary entities** (`<Entity>` placeholders resolve to these): `CharacterEntity`, `LocationEntity`,
  `EpisodeEntity`
- **Backend / API** (if any): `https://rickandmortyapi.com/api` — paginated `/character`, `/location`,
  `/episode` endpoints plus `/character/{id}` detail

## 7. Excluded Roles (N/A for this project)

List the roles that do not apply, so reviewers know their absence is intentional and the
corresponding generic-standard sections are deliberately skipped.

- **SPM modularization of app layers** — folder-based Clean Architecture inside a single app target;
  only `SnapshotTestKit` is extracted as a local SPM package for screenshot tests
- **SwiftData / Core Data** — no structured local model persistence
- **Keychain** — no secrets/tokens stored locally
- **Swift 6 language mode / Strict Concurrency = Complete** — project uses Swift 5.0 with targeted
  concurrency checking; revisit when raising deployment target or migrating dependencies
