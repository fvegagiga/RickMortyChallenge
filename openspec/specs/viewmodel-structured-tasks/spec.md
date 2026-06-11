# Capability: ViewModel Structured Tasks

## Purpose

Defines structured-concurrency patterns for ViewModel background work in the Presentation layer — specifically widget snapshot side effects and search debounce — without unstructured `Task.detached` unless explicitly justified.

## Requirements

### Requirement: Widget image downloads use structured concurrent tasks

`CharactersListViewModel` SHALL NOT use `Task.detached` for widget image downloads. Background download work SHALL start with `Task { @concurrent in ... }` (or equivalent) and `await` the actor-isolated store API.

#### Scenario: Snapshot write stays on MainActor, downloads run concurrently

- **WHEN** `writeWidgetSnapshot()` runs after a successful character fetch
- **THEN** snapshot encoding and `writeSnapshot` SHALL complete on `@MainActor` and image downloads SHALL run in a structured background task that awaits `store.downloadImages(for:)`

#### Scenario: No unstructured detached task for widget side effect

- **WHEN** inspecting `CharactersListViewModel.writeWidgetSnapshot()`
- **THEN** the implementation SHALL NOT contain `Task.detached`

### Requirement: Search debounce waits off the main actor

Search debounce in `CharactersListViewModel.onSearchTextChanged()` SHALL perform `Task.sleep` inside a `@concurrent` task entry (or off-main waiting) and SHALL hop back to `@MainActor` only for `performSearch()` state mutations.

#### Scenario: Debounce does not block MainActor during sleep

- **WHEN** the user types in the search field triggering debounce
- **THEN** the 500 ms wait SHALL NOT hold `@MainActor` isolation for the duration of the sleep

#### Scenario: Cancelled debounce does not apply stale search

- **WHEN** a new keystroke cancels the prior debounce task before sleep completes
- **THEN** the cancelled task SHALL NOT invoke `performSearch()`

#### Scenario: Successful debounce triggers search on MainActor

- **WHEN** the debounce interval elapses without cancellation
- **THEN** `performSearch()` SHALL run on `@MainActor` and update `viewState` as today

### Requirement: Existing ViewModel fetch semantics unchanged

Pagination, pull-to-refresh, error handling, and widget snapshot content rules in `CharactersListViewModel` SHALL remain behaviourally identical aside from concurrency safety improvements.

#### Scenario: loadInitial guard unchanged

- **WHEN** `loadInitial()` is called while `viewState` is not `.idle`
- **THEN** the method SHALL return without fetching

#### Scenario: Widget snapshot still shuffles and caps at 20

- **WHEN** characters are successfully loaded and `appGroupStore` is non-nil
- **THEN** the written snapshot SHALL contain up to 20 shuffled characters with the same `CharacterWidgetData` mapping as before

### Requirement: ViewModel task tests cover debounce and widget side effects

`CharactersListViewModelWidgetTests` (and related tests) SHALL be updated to validate async store interactions and debounce cancellation under the new task structure.

#### Scenario: Widget tests await async store calls

- **WHEN** widget integration tests run after a fetch
- **THEN** they SHALL `await` ViewModel load methods and assert `writeSnapshot` / `downloadImages` call counts on the mock store
