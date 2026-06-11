# Capability: Thread-Safe App Group Store

## Purpose

Defines actor-isolated widget snapshot and image download storage via `AppGroupStore` and `AppGroupStoreProtocol`. Complements `character-data-sharing` with concurrency safety requirements for shared App Group persistence under parallel access.

## Requirements

### Requirement: App group store is actor-isolated

The concrete `AppGroupStore` SHALL be declared as an `actor` so snapshot persistence (`UserDefaults`) and widget image file I/O are serialized and safe under parallel access.

#### Scenario: Snapshot write and read are isolated

- **WHEN** `writeSnapshot(_:)` is called followed by `currentCharacter()` or `totalCount()`
- **THEN** reads SHALL reflect the written snapshot without interleaving partial state from concurrent writers

#### Scenario: Parallel image downloads use structured concurrency inside the actor

- **WHEN** `downloadImages(for:)` is invoked with multiple characters
- **THEN** downloads SHALL use `withTaskGroup` (or equivalent structured concurrency) while snapshot and index mutations remain actor-isolated

### Requirement: App group store protocol remains the DI boundary

`AppGroupStoreProtocol` SHALL remain the injection type used by `DIContainer`, ViewModels, and the widget extension. Protocol requirements that cross actor boundaries SHALL be `async` where they invoke actor-isolated state.

#### Scenario: ViewModel writes snapshot on main actor

- **WHEN** `CharactersListViewModel` updates the widget snapshot after a successful fetch
- **THEN** it SHALL `await` the store's write API without blocking structured concurrency rules for subsequent background image downloads

#### Scenario: Widget provider reads current character

- **WHEN** `CharacterWidgetProvider` builds a timeline entry
- **THEN** it SHALL obtain snapshot data through the protocol using synchronous read helpers only where they do not cross unsafe isolation (or via `await` if reads become async)

### Requirement: Sendable contract is accurate

Types crossing task boundaries (`CharacterWidgetData`, snapshot arrays) SHALL remain `Sendable` value types. The store protocol SHALL NOT claim `Sendable` for mutable reference semantics without actor isolation on the concrete type.

#### Scenario: Snapshot payload is Sendable

- **WHEN** a `[CharacterWidgetData]` snapshot is passed into `downloadImages(for:)` from a `@MainActor` ViewModel task
- **THEN** the payload SHALL compile under strict concurrency checking without `@unchecked Sendable` on domain/widget data types

#### Scenario: Mock store supports tests

- **WHEN** unit tests inject `MockAppGroupStore`
- **THEN** the mock SHALL conform to `AppGroupStoreProtocol` with the same async surface and SHALL be safe for use from `@MainActor` test suites

### Requirement: Existing widget persistence behaviour is preserved

Actor isolation SHALL NOT change user-visible widget behaviour: snapshot overwrite resets index to zero, image files are stored at `{appGroup}/Library/Caches/widget-images/{id}.jpg`, and downloads skip existing files.

#### Scenario: writeSnapshot resets index

- **WHEN** a new snapshot is written
- **THEN** `currentIndex()` SHALL return `0`

#### Scenario: downloadImages skips existing files

- **WHEN** an image file already exists for a character ID
- **THEN** `downloadImages(for:)` SHALL NOT re-download that image

#### Scenario: AppGroupStoreTests remain valid

- **WHEN** existing `AppGroupStoreTests` are updated for async actor APIs
- **THEN** all prior behavioural assertions SHALL continue to pass
