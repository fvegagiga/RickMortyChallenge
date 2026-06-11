## MODIFIED Requirements

### Requirement: App group store is actor-isolated

The concrete `AppGroupStore` SHALL be declared as an `actor` so snapshot persistence (`writeSnapshot`) and widget image file I/O (`downloadImages`) are serialized through actor isolation. Widget-facing read helpers (`currentCharacter`, `currentIndex`, `setCurrentIndex`, `totalCount`, `imageURL`) SHALL remain `nonisolated` because WidgetKit requires synchronous reads; their `UserDefaults` access is not fully serialized by the actor.

#### Scenario: Snapshot write serializes through the actor

- **WHEN** `writeSnapshot(_:)` is called
- **THEN** encoding and writing `widget.characters` and resetting `widget.currentIndex` to 0 SHALL complete within the actor's isolation domain without interleaving another `writeSnapshot` call

#### Scenario: Widget reads use nonisolated UserDefaults access

- **WHEN** `CharacterWidgetProvider` calls `currentCharacter()` or `currentIndex()` synchronously
- **THEN** the read SHALL NOT require `await` and SHALL use the documented two-key `UserDefaults` invariant (`widget.characters`, `widget.currentIndex`)

#### Scenario: Parallel image downloads use structured concurrency inside the actor

- **WHEN** `downloadImages(for:)` is invoked with multiple characters
- **THEN** downloads SHALL use `withTaskGroup` (or equivalent structured concurrency) while snapshot and index mutations remain actor-isolated

## ADDED Requirements

### Requirement: App group store download tests cover concurrency behaviour

`AppGroupStoreTests` SHALL include Swift Testing cases for `downloadImages(for:)` covering skip-existing, download-when-missing, and parallel completion.

#### Scenario: downloadImages skips existing file

- **WHEN** `{characterId}.jpg` already exists in the widget image cache directory and `downloadImages(for:)` is called for that character
- **THEN** the network layer SHALL NOT re-download that image

#### Scenario: downloadImages persists missing files

- **WHEN** a character has a valid `imageURL`, the image file is missing, and a stubbed network response returns image data
- **THEN** `downloadImages(for:)` SHALL write `{characterId}.jpg` to the widget image cache directory

#### Scenario: parallel downloadImages completes without crash

- **WHEN** `downloadImages(for:)` is invoked concurrently for multiple characters via structured concurrency
- **THEN** all download tasks SHALL complete without crash

### Requirement: UserDefaults two-key invariant is documented in code

`AppGroupStore.swift` SHALL include a brief comment documenting the two-key `UserDefaults` invariant (`widget.characters`, `widget.currentIndex`) and why widget reads remain `nonisolated`.

#### Scenario: Invariant comment present at storage keys

- **WHEN** inspecting `AppGroupStore` source
- **THEN** a comment SHALL explain that cross-key atomicity is best-effort via write ordering in `writeSnapshot`, not a transactional guarantee
