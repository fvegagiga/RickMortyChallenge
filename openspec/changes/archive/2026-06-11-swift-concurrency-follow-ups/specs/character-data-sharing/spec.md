## MODIFIED Requirements

### Requirement: App writes a randomized character snapshot to shared storage after successful load

The system SHALL write a snapshot of 20 randomly selected characters from the currently loaded pool to the shared App Group UserDefaults after every successful character list load or refresh. Snapshot writes SHALL use the async `AppGroupStore.writeSnapshot(_:)` API; see `thread-safe-app-group-store` for actor isolation and concurrency details.

#### Scenario: Initial load succeeds

- **WHEN** `CharactersListViewModel.loadInitial()` transitions to `ViewState.success`
- **THEN** `await AppGroupStore.writeSnapshot(_:)` is called with 20 characters randomly sampled from the loaded pool (`allCharacters.shuffled().prefix(20)`)
- **AND** each character's image is downloaded and saved to the shared App Group FileManager container as `<characterId>.jpg`

#### Scenario: Refresh succeeds

- **WHEN** `CharactersListViewModel.refresh()` transitions to `ViewState.success`
- **THEN** `await AppGroupStore.writeSnapshot(_:)` is called with a new random sample of 20 characters from the refreshed pool, overwriting the previous snapshot

#### Scenario: Pool smaller than 20 characters

- **WHEN** the loaded pool contains fewer than 20 characters
- **THEN** `await AppGroupStore.writeSnapshot(_:)` is called with all available characters (shuffled), without padding

#### Scenario: Load fails

- **WHEN** `CharactersListViewModel.loadInitial()` transitions to `ViewState.failure`
- **THEN** `AppGroupStore` is NOT written — the previous snapshot (if any) is preserved

#### Scenario: App Group not available

- **WHEN** `AppGroupStore` cannot access the App Group (misconfigured entitlement)
- **THEN** the write operation logs an error and fails silently — it does not affect the main app's ViewState

### Requirement: AppGroupStore encapsulates all shared storage access

The system SHALL provide an `AppGroupStore` type in the Core layer that is the single point of access for reading and writing widget data in the shared App Group. Mutating operations (`writeSnapshot`, `downloadImages`) SHALL be `async` and actor-isolated; see `thread-safe-app-group-store` for concurrency requirements.

#### Scenario: Write character snapshot

- **WHEN** `await AppGroupStore.writeSnapshot(_:)` is called with an array of `CharacterWidgetData`
- **THEN** the array is JSON-encoded and stored under the key `widget.characters` in the App Group UserDefaults
- **AND** the current index key `widget.currentIndex` is reset to 0
- **AND** the array order is preserved as received (randomization is the caller's responsibility)

#### Scenario: Read current character

- **WHEN** `AppGroupStore.currentCharacter()` is called
- **THEN** it returns the `CharacterWidgetData` at the stored `widget.currentIndex`, or `nil` if the snapshot is empty

#### Scenario: Read/write current index

- **WHEN** `AppGroupStore.setCurrentIndex(_:)` is called with a valid index
- **THEN** the value is persisted to `widget.currentIndex` in the App Group UserDefaults
- **AND** `AppGroupStore.currentIndex()` returns the same value on next call
