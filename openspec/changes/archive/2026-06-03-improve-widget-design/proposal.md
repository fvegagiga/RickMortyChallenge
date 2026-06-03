## Why

The current widget uses raw SwiftUI styling (hardcoded fonts, colors, and spacing) rather than the project's design system tokens, and shows minimal character information. Users see no character status, no index counter, and no Rick & Morty branding — making the widget feel generic and disconnected from the main app.

## What Changes

- Replace hardcoded fonts and colors with `DSTypography` and `DSColors` tokens throughout the widget views.
- Add a status indicator dot (alive / dead / unknown) using `Color.DS.statusAlive/statusDead/statusUnknown` next to the character name.
- Add an index counter (e.g. "3 / 10") above or below the navigation arrows so users know where they are in the list.
- Apply a portal-green accent to the navigation chevron buttons using `Color.DS.portalGreen`.
- Improve the placeholder state with an icon and "Open the app to load characters" copy.
- Improve the gradient/material overlay in the small layout for better readability on bright images.
- Extend `CharacterWidgetData` to include `status` field so the widget can render the status dot.

## Capabilities

### New Capabilities

- `widget-character-status-indicator`: Displays a color-coded status dot (Alive / Dead / Unknown) alongside the character name using the project's design system status colors.
- `widget-index-counter`: Shows the current character index and total count in the navigation bar (e.g. "3 / 10").

### Modified Capabilities

- `character-widget`: Visual redesign — adds status dot, index counter, portal-green button accents, improved placeholder, and design system token adoption. No behavioral requirement changes to navigation or data-sharing; layout changes only.

## Impact

- **Presentation layer**: `CharacterWidgetView.swift` (all subviews redesigned), `CharacterWidgetEntry.swift` if preview data needs updating.
- **Core/Storage layer**: `CharacterWidgetData.swift` — add `status: String` field and propagate through `AppGroupStore` serialization.
- **Data layer**: `CharacterWidgetDataMapper` or equivalent — map character status string when writing to shared storage.
- **No API or networking changes** required.
- **No breaking changes** to existing navigation intents or the App Group contract (additive field).

## Non-goals

- Adding a new widget family (e.g., `.systemLarge` or lock-screen families) is out of scope.
- Deep-link navigation from the widget to a specific character detail screen is out of scope.
- Animated transitions between characters are out of scope.

## Test Strategy

- **Unit tests**: Update `CharacterNavigationIntentTests` and `CharactersListViewModelWidgetTests` to cover the new `status` field in `CharacterWidgetData`.
- **Simulator verification**: Run the widget extension on iPhone 15 simulator, confirm both systemSmall and systemMedium layouts render correctly with status dot, index counter, and portal-green accents.
- **XCUITest**: Not required for widget-only visual changes (WidgetKit previews cover layout validation).
