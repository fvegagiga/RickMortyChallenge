---
description: iOS Data and Domain layer standards, best practices, and conventions for Swift/SwiftUI projects using Clean Architecture — including repository pattern, use cases, networking, dependency injection, and testing practices.
globs: ["**/*.swift"]
alwaysApply: true
---

# iOS Data & Domain Layer Standards

## Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Applicability (Core vs Optional)](#applicability-core-vs-optional)
- [Architecture Overview](#architecture-overview)
  - [Clean Architecture Layers](#clean-architecture-layers)
  - [Project Structure](#project-structure)
- [Domain Layer](#domain-layer)
  - [Entities](#entities)
  - [Repository Protocols](#repository-protocols)
  - [Use Cases](#use-cases)
- [Data Layer](#data-layer)
  - [DTOs](#dtos)
  - [Mappers](#mappers)
  - [Repository Implementations](#repository-implementations)
  - [Networking](#networking)
- [Core Layer](#core-layer)
  - [Dependency Injection](#dependency-injection)
  - [Image Caching](#image-caching)
- [Coding Standards](#coding-standards)
  - [Naming Conventions](#naming-conventions)
  - [Swift Usage](#swift-usage)
  - [Concurrency](#concurrency)
  - [Error Handling](#error-handling)
- [Testing Standards](#testing-standards)
  - [Unit Tests](#unit-tests)
  - [Mocks](#mocks)
  - [Test Organization](#test-organization)
  - [Coverage Requirements](#coverage-requirements)
- [Performance Best Practices](#performance-best-practices)
- [Security Best Practices](#security-best-practices)
- [Related: Advanced & Optional Topics](#related-advanced--optional-topics)

---

## Overview

This document defines standards for the Data and Domain layers of iOS Swift/SwiftUI projects. The architecture follows Clean Architecture principles with strict separation between Domain (pure business logic), Data (network/persistence implementations), and Core (shared infrastructure). All code must be written in Swift with full type safety.

> Conventions: throughout this guide, replace the placeholders with your project's real names:
> `<AppName>` is the app/target/scheme, `<AppName>Tests` is the unit test target,
> `<Entity>` is a domain entity (for example `Product`, `User`, `Order`), and
> `<Feature>` is a presentation feature/screen group.

> **Generic vs project-specific (two-tier model).** This document defines *principles* and
> *roles* that hold for essentially any Clean Architecture Swift app. The *concrete choices* for a
> given project — which networking abstraction, dependency-injection mechanism, navigation
> strategy, persistence, design tokens, deployment target, and test framework — live in
> **`docs/project-profile.md`**. Where this guide names a concrete type (for example a
> `DIContainer`, a `Network` package, or a `CachedAsyncImageView`), treat it as an *illustrative
> example*: the binding decision for your project is whatever `project-profile.md` records.
> When you import these standards into a project, run the `adapt-standards` skill first — it fills
> in `project-profile.md` (analyzing an existing codebase, or applying recommended defaults for a
> new one) and prunes any section that does not apply.

## Technology Stack

- **Swift**: Primary language — strict typing, value semantics, Sendable conformance
- **SwiftUI**: UI framework (see `docs/presentation-standards.md` for Presentation layer standards)
- **async/await**: Concurrency model for all asynchronous operations
- **Networking**: HTTP through a networking abstraction behind a protocol — `URLSession` directly,
  or a third-party client if the project adopted one *(only when the app consumes a remote API; the
  concrete choice is recorded in `docs/project-profile.md`)*
- **Testing**: a single unit/integration framework per target — **Swift Testing** or **XCTest**
  (see [Testing Standards](#testing-standards))
- **Swift Package Manager**: Dependency and local package management

## Applicability (Core vs Optional)

This guide describes a complete, opinionated reference app. Not every concern applies to
every project — adapt it to your domain. Treat the following as a baseline:

- **Always apply**: Clean Architecture layering and the dependency rule, type safety,
  `async/await`, `Sendable`, naming conventions, error handling, testing discipline.
- **Apply when relevant** (skip or replace if your project does not need them):
  - **Networking abstraction / DTOs / Mappers / endpoint catalog** — only when consuming a remote
    API. A fully offline app may have no Data network layer at all.
  - **Paginated result type / pagination** — only for paginated endpoints or large collections.
  - **Image caching component** — only when the app loads remote images.
  - **Persistence (SwiftData / Core Data / Keychain)** — only when the app stores data
    locally (see `docs/advanced-topics.md`).
  - **Retry / transient-failure handling** — only when transient network failures matter.

When a concern does not apply, do not introduce its abstractions just to follow the template.
The `adapt-standards` skill removes the non-applicable ones based on `docs/project-profile.md`.

Advanced and optional topics — **SPM modularization**, **local persistence**, and
**Swift 6 strict concurrency** — live in `docs/advanced-topics.md` to keep these core standards
focused. Apply them only when your project needs them.

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────┐
│         Presentation            │  ViewModels + SwiftUI Views
├─────────────────────────────────┤
│           Domain                │  Entities · Repository Protocols · Use Cases
├─────────────────────────────────┤
│            Data                 │  DTOs · Mappers · RepositoryImpl · Networking
├─────────────────────────────────┤
│            Core                 │  Composition root · Shared infra · Design system
└─────────────────────────────────┘
```

**Dependency rule**: outer layers depend on inner layers. Domain has zero dependencies on Data or Core infrastructure. Use Cases depend only on repository protocols defined in Domain.

### Project Structure

The layout below is one **illustrative** organization of the four layers. The folder names, and
which optional pieces exist, depend on the project — record the actual structure in
`docs/project-profile.md`. What is *not* negotiable is the layer separation and the dependency
rule; everything labeled with a concrete file name is an example of the *role* it plays.

```
<AppName>/
├── Core/                              # Cross-cutting infrastructure
│   ├── DI/                            # Composition root (role: where dependencies are wired)
│   ├── DesignSystem/                  # Design tokens (colors, spacing, typography)
│   ├── Extensions/
│   ├── Navigation/                    # Navigation strategy (role: routing between screens)
│   └── Utilities/                     # e.g. an image-loading/caching component, if needed
├── Data/
│   ├── DTOs/                          # Decodable network/persistence models
│   ├── Mappers/                       # DTO → Entity transformations
│   ├── Network/                       # Networking abstraction + endpoint definitions
│   └── Repositories/                  # Protocol implementations
├── Domain/
│   ├── Entities/                      # Pure Swift value types
│   ├── Repositories/                  # Protocol contracts (+ paginated result type if used)
│   └── UseCases/                      # Single-responsibility interactors
└── Presentation/
    └── [Feature]/
        ├── ViewModels/
        └── Views/
```

> For larger codebases you can promote these layers/features to **Swift Package Manager modules**
> so the dependency rule is enforced by the compiler. See the *Modularization Variant (SPM)* in
> `docs/advanced-topics.md`. Whether a project is a single target or modularized is recorded in
> `docs/project-profile.md`.

## Domain Layer

The Domain layer contains only pure Swift — no imports of Foundation networking, no UIKit, no third-party frameworks. It defines contracts that the Data layer fulfills.

### Entities

Entities are value types (`struct`) representing core domain concepts. They must be `Sendable`.

```swift
// Good
struct <Entity>Entity: Identifiable, Sendable {
    let id: Int
    let name: String
    let status: <Entity>Status
    let category: String
    let kind: <Entity>Kind
    let originName: String
    let currentLocationName: String
    let imageURL: URL?
    let relatedURLs: [String]
    let created: Date
}

// Avoid: class with mutable state, or coupling to network/persistence types
```

- Use `enum` for finite state types (e.g., `<Entity>Status`, `<Entity>Kind`)
- All enum cases must be exhaustively handled — never use `default:` to suppress warnings
- Entities must not contain business logic that belongs to Use Cases

### Repository Protocols

Repository protocols define the contract between Domain and Data. They live in `Domain/Repositories/`.

```swift
protocol <Entity>RepositoryProtocol {
    func fetch<Entity>List(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity>
    func fetch<Entity>Detail(id: Int) async throws -> <Entity>Entity
}
```

Rules:
- One protocol per aggregate root (e.g., `<EntityA>`, `<EntityB>`, `<EntityC>`)
- Method names must describe intent, not implementation (`fetch<Entity>List`, not `getFromAPI`)
- Paginated results use `PagedResult<T>` — never return raw arrays from paginated endpoints
- All methods are `async throws` — never use completion handlers

```swift
struct PagedResult<T: Sendable>: Sendable {
    let items: [T]
    let hasNextPage: Bool
    let totalCount: Int
}
```

### Use Cases

Use Cases encapsulate a single business operation. Each has one `execute` method.

```swift
protocol Get<Entity>ListUseCaseProtocol {
    func execute(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity>
}

final class Get<Entity>ListUseCase: Get<Entity>ListUseCaseProtocol {
    private let repository: <Entity>RepositoryProtocol

    init(repository: <Entity>RepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity> {
        try await repository.fetch<Entity>List(page: page, name: name)
    }
}
```

Rules:
- One class per use case, named `[Verb][Noun]UseCase` (e.g., `Get<Entity>ListUseCase`, `Get<Entity>DetailUseCase`)
- Always define a protocol alongside the class to allow test injection
- Inject repository via constructor — never instantiate repositories inside use cases
- Use Cases must not contain UI logic or reference ViewModels

## Data Layer

### DTOs

DTOs are `Decodable` structs that map 1:1 to the network response format.

```swift
struct <Entity>DTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let category: String
    let kind: String
    let origin: LocationReferenceDTO
    let location: LocationReferenceDTO
    let image: String
    let related: [String]
    let created: String
}
```

Rules:
- DTOs live in `Data/DTOs/` and are never exposed beyond the Data layer
- Use `CodingKeys` only when the JSON key differs significantly from Swift naming
- DTOs must not contain business logic — they are pure data containers
- Avoid `Optional` fields unless the API genuinely returns null; prefer empty strings/arrays

### Mappers

Mappers transform DTOs into Domain Entities. They encapsulate all parsing logic (date formatting, URL construction, enum mapping).

```swift
final class <Entity>Mapper {
    func map(_ dto: <Entity>DTO) -> <Entity>Entity {
        <Entity>Entity(
            id: dto.id,
            name: dto.name,
            status: <Entity>Status(rawValue: dto.status.lowercased()) ?? .unknown,
            // ...
        )
    }

    func map(_ dtos: [<Entity>DTO]) -> [<Entity>Entity] {
        dtos.map { map($0) }
    }
}
```

Rules:
- One mapper per entity type, named `[Entity]Mapper`
- Mappers are `final class` (injected, not subclassed)
- Never let invalid DTO data crash — use safe fallbacks (`?? .unknown`, `?? []`)
- Date parsing belongs in the mapper, not in the DTO or Entity

### Repository Implementations

Implementations wire together the network service and mapper to satisfy the protocol.

```swift
final class <Entity>RepositoryImpl: <Entity>RepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let mapper: <Entity>Mapper

    init(networkService: NetworkServiceProtocol, mapper: <Entity>Mapper) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func fetch<Entity>List(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity> {
        let response: PaginatedResponseDTO<<Entity>DTO> = try await networkService.fetch(
            APIEndpoint.<entity>List(page: page, name: name)
        )
        return PagedResult(
            items: mapper.map(response.results),
            hasNextPage: response.info.next != nil,
            totalCount: response.info.count
        )
    }
}
```

Rules:
- Never expose DTOs outside the repository implementation
- Propagate errors upward with `throws` — never swallow errors silently
- Repository implementations are `final` and wired through the composition root

### Networking

> Applies only when the app consumes a remote API. Offline or local-only apps can omit this
> section entirely along with DTOs, mappers, and endpoint definitions.

All HTTP access goes through a **networking abstraction defined as a protocol** (role:
`NetworkServiceProtocol`). The concrete implementation — `URLSession` directly, a thin in-house
client, or a third-party library — is the project's choice, recorded in `docs/project-profile.md`.
The repositories depend only on the protocol, never on the concrete client, so the implementation
can be swapped or mocked freely.

Endpoints are defined in a **single type-safe place** (role: an `APIEndpoint` enum or equivalent
request builder), never as raw URL strings scattered across repositories:

```swift
// Example: endpoints as a typed enum (one illustrative shape of the "endpoint catalog" role)
enum APIEndpoint {
    case <entity>List(page: Int, name: String?)
    case <entity>Detail(id: Int)
    case <otherEntity>List(page: Int)
}
```

Rules:
- New endpoints are added to the central endpoint catalog — never construct raw URL strings inline
- Cross-cutting concerns (retry, auth headers, logging) belong in a decorator/wrapper around the
  networking abstraction, not in repositories or ViewModels — adopt them only when the project needs
  them, and record the approach in `project-profile.md`
- Tests inject a mock conforming to the networking protocol directly — never wrap mocks with
  production decorators (retry, caching, etc.)
- All network errors must be typed (a dedicated `Error` enum) — never throw `NSError` or raw strings

> **N/A for structured local persistence in this project** — see `docs/project-profile.md`.
> Domain data is remote-only; widget sharing uses `AppGroupStore` outside the repository layer.
> For projects that need local storage, persistence (SwiftData / Core Data / Keychain / UserDefaults)
> lives behind the same repository protocols. See the *Persistence Layer* section in
> `docs/advanced-topics.md`.

## Core Layer

### Dependency Injection

Dependencies are wired in a **single composition root**, created once at app startup. The
*mechanism* is the project's choice (recorded in `docs/project-profile.md`): a hand-written
container, SwiftUI's `@Environment`, or a DI library. Whatever the mechanism, the principles are
the same — **constructor injection** of protocols, no service locators buried inside types, and no
global singletons outside the composition root.

The example below shows one common shape (a hand-written container exposing factory methods):

```swift
// Example composition root — the role is "single place where concrete dependencies are wired"
final class DIContainer {
    let networkService: NetworkServiceProtocol
    let <entity>Repository: <Entity>RepositoryProtocol
    // ...

    // ViewModel factories — return new instances so each screen owns its state
    func make<Feature>ListViewModel() -> <Feature>ListViewModel {
        <Feature>ListViewModel(
            get<Entity>ListUseCase: Get<Entity>ListUseCase(repository: <entity>Repository)
        )
    }
}
```

Rules:
- Inject dependencies through initializers as **protocols** — never instantiate concrete
  collaborators inside a type
- Repositories are typically shared (stateless, safe to reuse); ViewModels are created per screen
- Tests build the unit under test with mocks directly (or instantiate the composition root with
  mock services)
- No singletons or global mutable state outside the composition root

### Image Caching

> Applies only when the app loads remote images. Skip this role entirely for asset-only UIs.

Remote image loading and caching are centralized behind a **single reusable component** (role:
an image cache + a caching image view) so views never re-implement download/cache logic. The
concrete type names and whether this role exists at all are recorded in `docs/project-profile.md`.

## Coding Standards

### Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Types (class, struct, enum, protocol) | PascalCase | `<Entity>Entity`, `NetworkError` |
| Properties and functions | camelCase | `fetch<Entity>List`, `hasNextPage` |
| Protocol names | Noun or `[Type]Protocol` | `<Entity>RepositoryProtocol` |
| Enum cases | camelCase | `.active`, `.noInternetConnection` |
| Constants | camelCase (let) | `let baseURL = ...` |
| Test subjects | `sut` | `var sut: <Feature>ListViewModel!` |

### Swift Usage

- **Access control**: always specify `private`, `internal`, `public` — never rely on defaults silently
- **`final`**: mark classes `final` unless inheritance is explicitly required
- **`let` over `var`**: prefer immutability; use `var` only when mutation is needed
- **Avoid `Any` and `AnyObject`**: use generics or protocols instead
- **Force unwrap**: forbidden except in tests with `XCTUnwrap` — use `guard let` or `if let`
- **`@discardableResult`**: only use when ignoring the result is genuinely valid

### Concurrency

- All async operations use `async/await` — no completion handlers, no Combine for data fetching
- ViewModels are `@MainActor` — they update `@Published` properties only on the main thread
- Domain and Data types must conform to `Sendable` when crossing actor boundaries
- Use `Task { }` in ViewModels to bridge sync (`onAppear`) to async operations
- Never use `DispatchQueue.main.async` — use `@MainActor` or `await MainActor.run { }` instead

```swift
// Good
@MainActor
final class <Feature>ListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[<Entity>Entity]> = .idle

    func loadInitial() async {
        // runs on @MainActor automatically
    }
}

// Avoid: manual dispatch
DispatchQueue.main.async { self.viewState = .success(items) }
```

> For new projects, target the **Swift 6 language mode** (or *Strict Concurrency = Complete*) so
> data races become compile-time errors. Guidance on `Sendable`, actor isolation, `@preconcurrency`,
> and typed throws (`throws(SpecificError)`) is in the *Swift 6 & Strict Concurrency* section of
> `docs/advanced-topics.md`.

### Error Handling

- Define typed error enums per layer (`NetworkError`, domain-specific errors if needed)
- Propagate errors with `throws` — never swallow with empty `catch {}`
- ViewModels catch errors and map them to `ViewState.failure(error)` for display
- Never show raw system error messages in the UI — map to user-friendly strings

```swift
enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case invalidResponse(statusCode: Int)
    case decodingFailed(Error)
    case unknown(Error)
}
```

## Testing Standards

### Unit Tests

All Domain and Data layer code must have unit tests. Test files live in `<AppName>Tests/` mirroring the source structure.

Two frameworks are acceptable — pick one per target and stay consistent:

- **Swift Testing** (`@Test`, `#expect`, `@Suite`) — preferred for new projects on recent toolchains;
  concise, parameterized tests, native `async`/`Sendable` support
- **XCTest** (`XCTestCase`) — for compatibility with older toolchains, UI tests (XCUITest), or
  existing suites

**Swift Testing example:**

```swift
import Testing

@MainActor
struct <Feature>ListViewModelTests {
    @Test
    func loadInitial_withSuccessfulResponse_setsSuccessState() async {
        let mockRepository = Mock<Entity>Repository()
        let items = MockDataFactory.make<Entity>Entities(count: 3)
        mockRepository.fetch<Entity>ListResult = .success(
            MockDataFactory.makePagedResult(items: items)
        )
        let sut = <Feature>ListViewModel(
            get<Entity>ListUseCase: Get<Entity>ListUseCase(repository: mockRepository)
        )

        await sut.loadInitial()

        guard case .success(let loaded) = sut.viewState else {
            Issue.record("Expected .success, got \(sut.viewState)")
            return
        }
        #expect(loaded.count == 3)
    }
}
```

**XCTest example:**

```swift
@MainActor
final class <Feature>ListViewModelTests: XCTestCase {
    var sut: <Feature>ListViewModel!
    var mockRepository: Mock<Entity>Repository!

    override func setUp() {
        super.setUp()
        mockRepository = Mock<Entity>Repository()
        sut = <Feature>ListViewModel(
            get<Entity>ListUseCase: Get<Entity>ListUseCase(repository: mockRepository)
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadInitial_withSuccessfulResponse_setsSuccessState() async {
        // Arrange
        let items = MockDataFactory.make<Entity>Entities(count: 3)
        mockRepository.fetch<Entity>ListResult = .success(
            MockDataFactory.makePagedResult(items: items)
        )

        // Act
        await sut.loadInitial()

        // Assert
        if case .success(let loaded) = sut.viewState {
            XCTAssertEqual(loaded.count, 3)
        } else {
            XCTFail("Expected .success state, got \(sut.viewState)")
        }
    }
}
```

### Mocks

- Mocks live in `<AppName>Tests/Mocks/`
- Each repository protocol has a corresponding `Mock[Name]Repository`
- Mocks expose `Result`-typed properties to configure success/failure per test
- Mocks track call counts and last parameters to verify interaction

```swift
final class Mock<Entity>Repository: <Entity>RepositoryProtocol {
    var fetch<Entity>ListResult: Result<PagedResult<<Entity>Entity>, Error> = .success(
        MockDataFactory.makePagedResult(items: [])
    )
    var fetch<Entity>ListCallCount = 0
    var lastFetchPage: Int?

    func fetch<Entity>List(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity> {
        fetch<Entity>ListCallCount += 1
        lastFetchPage = page
        return try fetch<Entity>ListResult.get()
    }
}
```

- `MockDataFactory` provides static factory methods for all entities and paged results
- Never use real network calls in unit tests

### Test Organization

Test methods follow the pattern: `test[Method]_[condition]_[expectedOutcome]`

```
testLoadInitial_withSuccessfulResponse_setsSuccessState
testLoadInitial_withNetworkError_setsFailureState
testLoadInitial_withEmptyResponse_setsEmptyState
testLoadMoreIfNeeded_whenNotLastItem_doesNotFetch
```

Group with `// MARK: - [method name]` sections within each test class.

### Coverage Requirements

- **ViewModels**: 100% of public methods must have happy path + error path tests
- **Use Cases**: test delegation to repository (mock repository, verify call)
- **Mappers**: test all field mappings including edge cases (empty strings, unknown enum values)
- **Repository Implementations**: test DTO-to-Entity mapping end-to-end via `MockNetworkService`
- Target: 90%+ line coverage across Domain and Data layers

## Performance Best Practices

- **Pagination**: for paginated or large collections, load pages on demand behind a paginated
  result type — never fetch all items at once *(skip when the dataset is small or unpaginated)*
- **Image caching**: when loading remote images, go through the shared caching component (memory +
  disk) — never re-download cached images *(skip for asset-only UIs)*
- **Retry logic**: when transient failures matter, handle them in the networking decorator — do not
  add retry loops in ViewModels *(skip when not needed)*
- **Task cancellation**: store `Task` references in ViewModels and cancel on `deinit` or `onDisappear` to avoid stale updates

## Security Best Practices

- **No hardcoded secrets**: base URLs and configuration live in the endpoint catalog or a config layer, never inlined ad hoc; secrets never ship in source
- **HTTPS only**: all network requests must use HTTPS — `App Transport Security` is not disabled
- **No sensitive data in logs**: never log user data, tokens, or full response bodies
- **Input sanitization**: validate and encode user-provided values before appending to URLs — centralize this in the endpoint catalog so it is applied consistently

## Related: Advanced & Optional Topics

The following optional topics are documented separately in `docs/advanced-topics.md`. Apply them
only when the project needs them:

- **Modularization Variant (SPM)** — splitting layers/features into Swift packages for large apps
- **Persistence Layer** — SwiftData / Core Data / Keychain / UserDefaults behind repositories
- **Swift 6 & Strict Concurrency** — language mode, `Sendable`, actor isolation, typed throws
