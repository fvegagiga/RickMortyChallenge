## Context

`CharactersListView` wires search text changes to debounced reload logic via SwiftUI's `onChange` modifier:

```swift
.onChange(of: viewModel.searchText) { _ in viewModel.onSearchTextChanged() }
```

This single-parameter closure overload was deprecated in iOS 17.0. The project minimum deployment target is iOS 17.0 (`docs/project-profile.md`), so the compiler emits a deprecation warning. The fix is Presentation-layer only; `CharactersListViewModel.onSearchTextChanged()` and search debounce behavior are unchanged.

## Goals / Non-Goals

**Goals:**
- Remove the deprecation warning by adopting the iOS 17+ `onChange` API.
- Preserve identical search behavior (same trigger on every `searchText` change).

**Non-Goals:**
- Refactoring search debounce logic in the ViewModel.
- Migrating other deprecated SwiftUI APIs in the project.
- Changing UI layout, navigation, or accessibility identifiers.

## Decisions

### Decision 1: Use the zero-parameter `onChange` closure

**Choice:** Replace the deprecated modifier with:

```swift
.onChange(of: viewModel.searchText) {
    viewModel.onSearchTextChanged()
}
```

**Rationale:** The handler does not use the old or new value; the zero-parameter overload is the simplest correct migration and matches Apple's recommended replacement when the change payload is ignored.

**Alternative considered — two-parameter closure:** `.onChange(of: viewModel.searchText) { _, _ in viewModel.onSearchTextChanged() }`. Rejected as unnecessary noise when neither parameter is read.

### Decision 2: No new or updated tests

**Choice:** Rely on existing `CharactersListViewModelTests` for search debounce behavior; no new Swift Testing or XCUITest cases.

**Rationale:** Behavior is unchanged; this is a compiler-warning fix only. Existing tests already cover `onSearchTextChanged()`.

### Decision 3: Skip simulator and XCUITest mandatory steps

**Choice:** Document skip rationale in `tasks.md` — no user-visible or interaction changes.

**Rationale:** Per `docs/openspec-tasks-mandatory-steps.md`, simulator and XCUITest steps apply only when UI or user-visible behavior changes.

## Risks / Trade-offs

- **[Risk] Accidental behavior change if wrong overload is used** → Mitigation: Run existing ViewModel unit tests; confirm `onSearchTextChanged()` still fires on text changes.
- **[Risk] Missing other deprecated `onChange` usages** → Mitigation: Grep the codebase; only `CharactersListView` uses this pattern today.

## Migration Plan

1. Update the single `onChange` line on a feature branch.
2. Build the project and confirm zero deprecation warnings for `CharactersListView`.
3. Run unit tests (`RickMortyChallengeTests`).
4. Merge via PR.

**Rollback:** Revert the one-line change.

## Open Questions

None.
