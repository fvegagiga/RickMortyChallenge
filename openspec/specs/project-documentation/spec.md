# Project Documentation

Requirements for keeping `README.md` and `RickMortyArchitecture.drawio` accurate and easy to understand relative to the implemented app.

## Requirements

### Requirement: README documents all implemented features

The `README.md` SHALL describe every user-facing feature currently implemented in the app, including Characters (list, search, detail, pagination), Locations (list, pagination), Episodes (list, pagination), and the Home Screen Widget (navigation, App Group data sharing).

#### Scenario: Features section is complete

- **WHEN** a contributor reads the Features section of `README.md`
- **THEN** they find accurate descriptions of all three tabs, character search and detail navigation, shared list behaviours (pagination, pull-to-refresh, loading/empty/error states), and the widget extension

#### Scenario: Stale file references are removed

- **WHEN** a contributor reads the Project Structure section of `README.md`
- **THEN** it does not reference removed files (`AppRoute.swift`, local `NetworkService.swift`, `NetworkServiceProtocol.swift`, `NetworkError.swift`) and instead reflects the current layout (`MainTabView`, `CharacterRoute` in `AppRouter.swift`, `Core/Storage/`, Network SPM package)

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

### Requirement: Architecture diagram is simple and accurate

The `RickMortyArchitecture.drawio` file SHALL present a simplified Clean Architecture overview readable at a glance, showing four layers (Presentation, Domain, Data, Core), the widget extension, external dependencies (Rick & Morty API, Network SPM, App Group), and key components per layer without per-class dependency wiring.

#### Scenario: Diagram uses current naming

- **WHEN** a reviewer opens `RickMortyArchitecture.drawio`
- **THEN** the diagram shows `MainTabView` (not `ContentView`), `CachedAsyncImageView` (not `AsyncCachedImage`), `CharacterRoute` only (not `LocationRoute` / `EpisodeRoute`), and includes `AppGroupStore` and the widget extension

#### Scenario: Diagram is not overly detailed

- **WHEN** a reviewer opens `RickMortyArchitecture.drawio` at 100% zoom on a standard display
- **THEN** the full architecture is visible without scrolling and contains at most one grouped box per layer plus external systems, with no individual ViewModel-to-UseCase edges

### Requirement: README references the architecture diagram

The `README.md` SHALL include a reference to `RickMortyArchitecture.drawio` in the Architecture section, instructing contributors to open it in draw.io (or diagrams.net) for a visual overview.

#### Scenario: Diagram link is present

- **WHEN** a contributor reads the Architecture section of `README.md`
- **THEN** they find a reference to `RickMortyArchitecture.drawio` and instructions to open it with draw.io
