---
description: Advanced and optional iOS Swift/SwiftUI topics that extend the core standards — SPM modularization, local persistence (SwiftData/Core Data/Keychain), and Swift 6 strict concurrency. Apply only when the project needs them.
alwaysApply: false
---

# iOS Advanced & Optional Topics

These topics extend the core standards but are **not required for every project**. Apply them
only when your project's size, lifecycle, or domain calls for them. The core rules still hold:
Clean Architecture, the dependency rule, type safety, `async/await`, `Sendable`, and testing
discipline (see `docs/domain-data-standards.md` and `docs/presentation-standards.md`).

> Conventions: replace placeholders with your project's real names — `<AppName>` is the
> app/target/scheme, `<Entity>` is a domain entity (for example `Product`, `User`, `Order`),
> and `<Feature>` is a presentation feature/screen group. Concrete type names (e.g. a composition
> root, persistence stores) are *illustrative roles*; the binding choices live in
> `docs/project-profile.md` (filled by the `adapt-standards` skill).

## Table of Contents

- [Modularization Variant (SPM)](#modularization-variant-spm)
- [Persistence Layer (Optional)](#persistence-layer-optional)
- [Swift 6 & Strict Concurrency](#swift-6--strict-concurrency)

---

## Modularization Variant (SPM)

> **N/A for this project** — see `docs/project-profile.md`. This app uses a single app target
> with folder-based Clean Architecture layers. Only `Packages/SnapshotTestKit` is extracted as a
> local SPM package for screenshot regression tests. The guidance below is retained as a migration
> reference for future modularization.

<details>
<summary>Reference: SPM modularization (not used in this project)</summary>

> Use when: large codebase, multiple teams, long build times, or you want the compiler to
> enforce architectural boundaries. Small-to-medium apps can stay with the folder-based
> structure in `docs/domain-data-standards.md`.

The folder-based structure in the core standards is the simplest layout and works well for
small-to-medium apps. For larger codebases, build times, or strict boundary enforcement, promote
the layers (or each feature) to **Swift Package Manager modules**. The same Clean Architecture
rules apply; the dependency rule is now enforced by the compiler through package dependencies.

```
<AppName>/                      # Thin app target: composition root + entry point
Packages/
├── Domain/                     # Pure Swift, no dependencies
├── Data/                       # depends on Domain (+ Networking)
├── Networking/                 # URLSession abstraction
├── DesignSystem/               # Tokens + reusable UI primitives
├── CoreUI/                     # Shared SwiftUI components
└── Features/
    ├── <FeatureA>/             # depends on Domain, DesignSystem, CoreUI
    └── <FeatureB>/
```

Guidelines:
- A feature module never imports another feature module — share through Domain/CoreUI
- The app target is the only place that links every module and wires the composition root
- Prefer many small modules with explicit dependencies over one large package
- Choose this variant up front for multi-team or large apps; migrating later is costly

</details>

## Persistence Layer (Optional)

> **N/A for structured local persistence in this project** — see `docs/project-profile.md`.
> Domain data is fetched remotely; the only local storage is `AppGroupStore` (app-group
> `UserDefaults` + widget image cache) for the Character Widget extension. No SwiftData, Core
> Data, or Keychain. The guidance below is retained as a migration reference.

<details>
<summary>Reference: structured persistence (not used in this project)</summary>

> Use when: the app stores data locally. Skip entirely if all state is remote or in-memory.

Local persistence lives behind the same repository protocols as networking, so the Domain layer
never knows whether data comes from the network, disk, or a cache. Choose the technology by need:

| Need | Recommended technology |
|---|---|
| Structured model graph, SwiftUI-first (iOS 17+) | **SwiftData** (`@Model`, `ModelContainer`) |
| Complex/legacy model graph, fine-grained control | **Core Data** (`NSPersistentContainer`) |
| Secrets, tokens, credentials | **Keychain** (never `UserDefaults`) |
| Small user preferences / flags | **UserDefaults** (`@AppStorage` in the UI layer) |
| Plain files / blobs | `FileManager` in the app sandbox |

Rules:
- Persistence types (`@Model` classes, `NSManagedObject`, on-disk DTOs) live in the Data layer
  and are **never** exposed beyond it — map them to Domain entities, exactly like network DTOs
- A repository may combine sources (e.g., return cached data, then refresh from network) behind
  one protocol method — the caller stays unaware
- Keep persistence access `async` and off the main thread for non-trivial work
- Sensitive data goes to the Keychain only; never log it or store it in `UserDefaults`

```swift
// Repository protocol is identical whether data is local, remote, or both
protocol <Entity>RepositoryProtocol {
    func fetch<Entity>List(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity>
}

// Implementation decides the source(s); Domain never knows
final class <Entity>RepositoryImpl: <Entity>RepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localStore: <Entity>LocalStoreProtocol   // e.g., SwiftData/Core Data wrapper

    func fetch<Entity>List(page: Int, name: String?) async throws -> PagedResult<<Entity>Entity> {
        // Example policy: serve cache, then refresh from network when available
        // ...
    }
}
```

</details>

## Swift 6 & Strict Concurrency

> **Partially applied (targeted checking)** — see `docs/project-profile.md`. The app uses Swift 5.0
> with `SWIFT_STRICT_CONCURRENCY = targeted`. Core shared mutable infrastructure already uses
> `actor` isolation (`ImageCacheManager`, `AppGroupStore`); ViewModels use `@MainActor` and
> structured `Task { @concurrent in }` for background side effects. Full Swift 6 / Complete
> checking is not enabled yet.

**Applied in this codebase (Swift 5 targeted):**

- `actor ImageCacheManager` with async `ImageCacheManagerProtocol` — serializes memory/disk cache access
- `actor AppGroupStore` with async writes/downloads and `nonisolated` widget read helpers backed by `UserDefaults` — see `openspec/specs/thread-safe-app-group-store/spec.md` for the two-key invariant and isolation boundaries
- `CharactersListViewModel` — debounce sleep off main actor; widget image downloads via structured concurrent tasks (no `Task.detached`)

<details>
<summary>Reference: Swift 6 strict concurrency (not fully adopted yet)</summary>

> Use when: starting a new project or migrating an existing one to safer concurrency. Recommended
> as the default for all new work.

Target the **Swift 6 language mode** (or at least enable *Strict Concurrency Checking = Complete*
in Swift 5 mode) for new projects. This turns data races into compile-time errors and makes the
`Sendable` discipline in the core standards mandatory rather than aspirational.

- **`Sendable` everywhere it crosses isolation**: entities, DTOs, and `PagedResult` are value
  types and conform to `Sendable`. Reference types shared across actors must be `Sendable` too
  (often via immutability or `@unchecked Sendable` with a documented justification)
- **Actor isolation**: ViewModels are `@MainActor`. Use a custom `actor` (or `@globalActor`) to
  protect shared mutable state such as in-memory caches — never a lock plus `@unchecked Sendable`
  unless there is a measured reason
- **No `@preconcurrency` as a permanent fix**: use it only as a temporary bridge for third-party
  APIs not yet `Sendable`-audited, and track its removal
- **Typed throws (Swift 6)**: prefer `throws(SpecificError)` when a function has a single,
  well-defined error domain — it documents intent and removes `as?` casts at the call site

```swift
// Typed throws: the caller knows exactly what can fail
func fetch<Entity>List(page: Int) async throws(NetworkError) -> PagedResult<<Entity>Entity>

// Protect shared mutable cache with an actor, not a lock
actor <Entity>MemoryCache {
    private var storage: [Int: <Entity>Entity] = [:]
    func value(for id: Int) -> <Entity>Entity? { storage[id] }
    func insert(_ entity: <Entity>Entity) { storage[entity.id] = entity }
}
```

</details>
