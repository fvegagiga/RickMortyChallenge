## Why

`CharactersListView` uses the single-parameter `onChange(of:perform:)` overload that Apple deprecated in iOS 17.0. The project targets iOS 17+, so the compiler emits a deprecation warning that should be resolved to keep the build clean and align with current SwiftUI APIs.

## What Changes

- Replace the deprecated `.onChange(of: viewModel.searchText) { _ in ... }` modifier in `CharactersListView` with the iOS 17+ two-parameter or zero-parameter `onChange` overload.
- No user-visible behavior change: search debouncing and `onSearchTextChanged()` invocation remain identical.

## Non-goals

- Migrating other SwiftUI APIs or refactoring `CharactersListView` beyond the `onChange` fix.
- Changing search behavior, debounce timing, or ViewModel logic.
- Adopting `@Observable` or other broader Presentation-layer modernizations.

## Capabilities

### New Capabilities

_None — this is an API modernization with no new product behavior._

### Modified Capabilities

_None — search-triggered refresh behavior is unchanged; only the SwiftUI modifier syntax updates._

## Impact

- **Clean Architecture layer**: Presentation (`CharactersListView.swift` only).
- **Affected code**: One line in `RickMortyChallenge/Presentation/Characters/Views/CharactersListView.swift`.
- **APIs / dependencies**: SwiftUI `onChange` modifier only; no new packages or Domain/Data changes.
- **Test strategy**: Existing unit and UI tests remain sufficient; run `xcodebuild test` to confirm no regressions. No new tests required (behavior unchanged). Simulator verification optional (compiler warning removal only).
