## MODIFIED Requirements

### Requirement: ViewModel task tests cover debounce and widget side effects

`CharactersListViewModelTests` and `CharactersListViewModelWidgetTests` SHALL validate async store interactions and debounce cancellation under the structured task implementation.

#### Scenario: Widget tests await async store calls

- **WHEN** widget integration tests run after a fetch
- **THEN** they SHALL `await` ViewModel load methods and assert `writeSnapshot` and `downloadImages` call counts on the mock store

#### Scenario: Debounce cancellation test exists

- **WHEN** `onSearchTextChanged()` is called twice before the 500 ms debounce elapses
- **THEN** a unit test SHALL verify the first debounce task does not invoke `performSearch()` (no fetch triggered)

#### Scenario: Successful debounce test exists

- **WHEN** debounce completes without cancellation
- **THEN** a unit test SHALL verify `performSearch()` runs and updates `viewState` on `@MainActor`
