---
description: iOS Data and Domain layer standards, best practices, and conventions for Swift/SwiftUI projects using Clean Architecture — including repository pattern, use cases, networking, dependency injection, and testing practices.
globs: ["RickMortyPersistImage/**/*.swift", "RickMortyPersistImageTests/**/*.swift", "packages/**/*.swift"]
alwaysApply: true
---

# iOS Data & Domain Layer Standards

## Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
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

---

## Overview

This document defines standards for the Data and Domain layers of iOS Swift/SwiftUI projects. The architecture follows Clean Architecture principles with strict separation between Domain (pure business logic), Data (network/persistence implementations), and Core (shared infrastructure). All code must be written in Swift with full type safety.

## Technology Stack

- **Swift**: Primary language — strict typing, value semantics, Sendable conformance
- **SwiftUI**: UI framework (see `docs/presentation-standards.md` for Presentation layer standards)
- **async/await**: Concurrency model for all asynchronous operations
- **URLSession**: HTTP networking via the `Network` local Swift package
- **XCTest**: Unit and integration testing framework
- **Swift Package Manager**: Dependency and local package management

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────┐
│         Presentation            │  ViewModels + SwiftUI Views
├─────────────────────────────────┤
│           Domain                │  Entities · Repository Protocols · Use Cases
├─────────────────────────────────┤
│            Data                 │  DTOs · Mappers · RepositoryImpl · Network
├─────────────────────────────────┤
│            Core                 │  DI · ImageCache · Extensions · DesignSystem
└─────────────────────────────────┘
```

**Dependency rule**: outer layers depend on inner layers. Domain has zero dependencies on Data or Core infrastructure. Use Cases depend only on repository protocols defined in Domain.

### Project Structure

```
RickMortyPersistImage/
├── Core/
│   ├── DI/
│   │   └── DIContainer.swift          # Central dependency container
│   ├── DesignSystem/
│   │   ├── DSColors.swift
│   │   ├── DSSpacing.swift
│   │   └── DSTypography.swift
│   ├── Extensions/
│   │   └── View+Extensions.swift
│   ├── Router/
│   │   └── AppRouter.swift
│   └── Utilities/
│       └── ImageCacheManager.swift
├── Data/
│   ├── DTOs/                          # Decodable network models
│   ├── Mappers/                       # DTO → Entity transformations
│   ├── Network/
│   │   └── APIEndpoint.swift
│   └── Repositories/                  # Protocol implementations
├── Domain/
│   ├── Entities/                      # Pure Swift value types
│   ├── Repositories/                  # Protocol contracts + PagedResult
│   └── UseCases/                      # Single-responsibility interactors
└── Presentation/
    └── [Feature]/
        ├── ViewModels/
        └── Views/
```

## Domain Layer

The Domain layer contains only pure Swift — no imports of Foundation networking, no UIKit, no third-party frameworks. It defines contracts that the Data layer fulfills.

### Entities

Entities are value types (`struct`) representing core domain concepts. They must be `Sendable`.

```swift
// Good
struct CharacterEntity: Identifiable, Sendable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: CharacterGender
    let originName: String
    let currentLocationName: String
    let imageURL: URL?
    let episodeURLs: [String]
    let created: Date
}

// Avoid: class with mutable state, or coupling to network/persistence types
```

- Use `enum` for finite state types (e.g., `CharacterStatus`, `CharacterGender`)
- All enum cases must be exhaustively handled — never use `default:` to suppress warnings
- Entities must not contain business logic that belongs to Use Cases

### Repository Protocols

Repository protocols define the contract between Domain and Data. They live in `Domain/Repositories/`.

```swift
protocol CharacterRepositoryProtocol {
    func fetchCharacters(page: Int, name: String?) async throws -> PagedResult<CharacterEntity>
    func fetchCharacterDetail(id: Int) async throws -> CharacterEntity
}
```

Rules:
- One protocol per aggregate root (Character, Location, Episode)
- Method names must describe intent, not implementation (`fetchCharacters`, not `getFromAPI`)
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
protocol GetCharactersUseCaseProtocol {
    func execute(page: Int, name: String?) async throws -> PagedResult<CharacterEntity>
}

final class GetCharactersUseCase: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        try await repository.fetchCharacters(page: page, name: name)
    }
}
```

Rules:
- One class per use case, named `[Verb][Noun]UseCase` (e.g., `GetCharactersUseCase`, `GetCharacterDetailUseCase`)
- Always define a protocol alongside the class to allow test injection
- Inject repository via constructor — never instantiate repositories inside use cases
- Use Cases must not contain UI logic or reference ViewModels

## Data Layer

### DTOs

DTOs are `Decodable` structs that map 1:1 to the network response format.

```swift
struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationReferenceDTO
    let location: LocationReferenceDTO
    let image: String
    let episode: [String]
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
final class CharacterMapper {
    func map(_ dto: CharacterDTO) -> CharacterEntity {
        CharacterEntity(
            id: dto.id,
            name: dto.name,
            status: CharacterStatus(rawValue: dto.status.lowercased()) ?? .unknown,
            // ...
        )
    }

    func map(_ dtos: [CharacterDTO]) -> [CharacterEntity] {
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
final class CharacterRepositoryImpl: CharacterRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let mapper: CharacterMapper

    init(networkService: NetworkServiceProtocol, mapper: CharacterMapper) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func fetchCharacters(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        let response: PaginatedResponseDTO<CharacterDTO> = try await networkService.fetch(
            APIEndpoint.characters(page: page, name: name)
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
- Repository implementations are `final` and injected via `DIContainer`

### Networking

The `Network` local Swift package contains `NetworkServiceProtocol` and `NetworkService`. All HTTP calls go through this protocol.

```swift
// APIEndpoint defines all endpoints as a typed enum
enum APIEndpoint {
    case characters(page: Int, name: String?)
    case characterDetail(id: Int)
    case locations(page: Int)
    case episodes(page: Int)
}
```

Rules:
- New endpoints must be added to `APIEndpoint` — never construct raw URL strings in repositories
- Use `RetryingNetworkService` in production builds (wraps the real `NetworkService`)
- Tests inject `MockNetworkService` directly — never wrap mocks with retry logic
- All network errors must be typed (`NetworkError` enum) — never throw `NSError` or raw strings

## Core Layer

### Dependency Injection

`DIContainer` is the single wiring point. It is created once at app startup and injected via `@EnvironmentObject`.

```swift
final class DIContainer: ObservableObject {
    let networkService: NetworkServiceProtocol
    let imageCacheManager: ImageCacheManagerProtocol
    let characterRepository: CharacterRepositoryProtocol
    // ...

    // ViewModel factories — return new instances so each screen owns its state
    func makeCharactersListViewModel() -> CharactersListViewModel {
        CharactersListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: characterRepository)
        )
    }
}
```

Rules:
- Repositories are shared (stateless, safe to reuse across ViewModels)
- ViewModels are created via factory methods — never shared
- Tests instantiate `DIContainer` with mock services, or construct ViewModels directly with mocks
- Never use singletons or global state outside `DIContainer`

### Image Caching

Image caching is centralized in `ImageCacheManager`. Views use `CachedAsyncImageView` — never use `AsyncImage` directly.

### Widget Shared Storage (App Group)

`AppGroupStore` (`Core/Storage/AppGroupStore.swift`) is the single point of access for sharing data between the main app and the WidgetKit extension via an App Group container.

App Group identifier: `group.com.fvg0902iosdev.RickMortyPersistImage.widget`

**Responsibilities:**
- Write/read a `[CharacterWidgetData]` snapshot to `UserDefaults(suiteName:)` under key `widget.characters`
- Persist the current widget navigation index under key `widget.currentIndex`
- Download and cache character images to the shared App Group `FileManager` container (`Library/Caches/widget-images/<id>.jpg`) so the widget can load them synchronously

**Pattern:**
- `CharactersListViewModel` calls `store.writeSnapshot(_:)` synchronously after `ViewState.success`, passing `Array(allCharacters.shuffled().prefix(20))` mapped to `CharacterWidgetData`
- Image download runs in a `Task.detached(priority: .background)` after the snapshot write — it does not block the UI
- `AppGroupStoreProtocol` allows mock injection in tests; inject `nil` to disable widget writes in test scenarios

**Key rule:** `AppGroupStore` is always injected via `DIContainer`. Never instantiate `AppGroupStore()` directly in ViewModels.

## Coding Standards

### Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Types (class, struct, enum, protocol) | PascalCase | `CharacterEntity`, `NetworkError` |
| Properties and functions | camelCase | `fetchCharacters`, `hasNextPage` |
| Protocol names | Noun or `[Type]Protocol` | `CharacterRepositoryProtocol` |
| Enum cases | camelCase | `.alive`, `.noInternetConnection` |
| Constants | camelCase (let) | `let baseURL = ...` |
| Test subjects | `sut` | `var sut: CharactersListViewModel!` |

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
final class CharactersListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[CharacterEntity]> = .idle

    func loadInitial() async {
        // runs on @MainActor automatically
    }
}

// Avoid: manual dispatch
DispatchQueue.main.async { self.viewState = .success(items) }
```

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

All Domain and Data layer code must have unit tests. Test files live in `RickMortyPersistImageTests/` mirroring the source structure.

```swift
@MainActor
final class CharactersListViewModelTests: XCTestCase {
    var sut: CharactersListViewModel!
    var mockRepository: MockCharacterRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        sut = CharactersListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: mockRepository)
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadInitial_withSuccessfulResponse_setsSuccessState() async {
        // Arrange
        let characters = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
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

- Mocks live in `RickMortyPersistImageTests/Mocks/`
- Each repository protocol has a corresponding `Mock[Name]Repository`
- Mocks expose `Result`-typed properties to configure success/failure per test
- Mocks track call counts and last parameters to verify interaction

```swift
final class MockCharacterRepository: CharacterRepositoryProtocol {
    var fetchCharactersResult: Result<PagedResult<CharacterEntity>, Error> = .success(
        MockDataFactory.makePagedResult(items: [])
    )
    var fetchCharactersCallCount = 0
    var lastFetchPage: Int?

    func fetchCharacters(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        fetchCharactersCallCount += 1
        lastFetchPage = page
        return try fetchCharactersResult.get()
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

- **Pagination**: always use `PagedResult` and load pages on demand — never fetch all items at once
- **Image caching**: use `ImageCacheManager` with disk + memory cache — never re-download cached images
- **Retry logic**: `RetryingNetworkService` handles transient failures automatically — do not add retry loops in ViewModels
- **Task cancellation**: store `Task` references in ViewModels and cancel on `deinit` or `onDisappear` to avoid stale updates

## Security Best Practices

- **No hardcoded secrets**: API base URLs in `APIEndpoint`, never inline
- **HTTPS only**: all network requests must use HTTPS — `App Transport Security` is not disabled
- **No sensitive data in logs**: never log user data, tokens, or full response bodies
- **Input sanitization**: validate and encode user-provided search strings before appending to URLs (already handled by `APIEndpoint` URL construction)
