## Context

The `CharacterWidget` currently uses raw SwiftUI constants for fonts, colors, and spacing, bypassing the project's `DSColors`, `DSTypography`, and `DSSpacing` design system tokens. It also lacks contextual information (character status, index position) that would make it more useful and visually aligned with the main app.

`CharacterWidgetData` (shared via App Group) currently carries only `id`, `name`, `imageFileName`, and `imageURL`. Adding a `status` field requires touching the Core/Storage layer and the Data layer mapper that writes to shared storage, while keeping the contract backwards-compatible.

## Goals / Non-Goals

**Goals:**
- Adopt `DSColors`, `DSTypography`, and `DSSpacing` tokens in all widget subviews.
- Show character `status` as a color-coded dot using `Color.DS.statusAlive/statusDead/statusUnknown`.
- Display a "3 / 10" style index counter in the navigation bar.
- Apply `Color.DS.portalGreen` accent to navigation chevron buttons.
- Improve the placeholder state copy and icon.
- Extend `CharacterWidgetData` with a `status: String` field (additive, non-breaking).

**Non-Goals:**
- New widget families (`.systemLarge`, lock-screen).
- Deep-link navigation to a character detail screen.
- Animated transitions between characters.

## Decisions

### Decision 1: Extend `CharacterWidgetData` with `status: String`

**Chosen approach:** Add `status: String` as an optional field with a default of `""` (empty string = unknown) so existing serialized payloads in the App Group container can still be decoded without crashes.

**Alternatives considered:**
- Adding a typed `CharacterStatus` enum — rejected because WidgetKit extensions cannot import Domain entities without shared framework overhead, and the enum would need to be duplicated or moved to Core.
- Ignoring status in the widget — rejected because the proposal explicitly calls for the status dot.

### Decision 2: Status dot color derived from string in the widget view

**Chosen approach:** `CharacterWidgetView` maps the raw `status` string to `Color.DS.statusAlive/statusDead/statusUnknown` via a small local computed property. No shared logic needed.

**Why this over a shared utility:** Widget extensions run in a separate process. A local mapping keeps the extension self-contained and avoids module coupling.

### Decision 3: Index counter sourced from `CharacterWidgetEntry`

**Chosen approach:** `CharacterWidgetEntry` already contains the full character list (or the provider can pass `currentIndex` and `totalCount` alongside the current character). We add `currentIndex: Int` and `totalCount: Int` to the entry.

**Alternatives considered:**
- Re-reading total count from `AppGroupStore` at render time — rejected because widget views should be pure given their entry; side effects at render time are an anti-pattern in WidgetKit.

### Decision 4: Design system tokens in widget extension

**Chosen approach:** `DSColors`, `DSSpacing`, and `DSTypography` live in `RickMortyPersistImage/Core/DesignSystem/`. The widget extension already links the main app target's source files. We reference the tokens directly.

**Note:** If the design system is ever extracted to a Swift Package, the symlink/module path must be updated.

## Risks / Trade-offs

- **App Group schema change** → `CharacterWidgetData` gains a new field. Old snapshots stored before this change will decode with an empty `status`, which will render as the "unknown" grey dot. This is acceptable UX.
- **Index counter requires provider change** → `CharacterWidgetProvider` must expose `currentIndex` and `totalCount` via the entry. If the provider becomes more complex, it may affect timeline reload performance. Mitigation: keep the data read synchronous and single-pass.
- **Design system in widget extension** → Linking Core source files increases widget binary size slightly. Not a concern for this project scale.

## Migration Plan

1. Update `CharacterWidgetData` (add `status` field with default).
2. Update the mapper/store that writes `CharacterWidgetData` to include status.
3. Update `CharacterWidgetEntry` (add `currentIndex`, `totalCount`).
4. Update `CharacterWidgetProvider` to populate the new entry fields.
5. Redesign `CharacterWidgetView` subviews using design system tokens.
6. Update unit tests and widget previews.

Rollback: Reverting the `CharacterWidgetData` field is safe because the App Group payload is overwritten on every app launch that syncs characters.
