## Why

Users want quick, glanceable access to Rick & Morty characters directly from the iOS home screen without opening the app. A navigable home screen widget lets users browse characters (image + name) at a glance, increasing engagement and making the app feel like a living part of the device.

## What Changes

- New Xcode target: `CharacterWidgetExtension` (WidgetKit extension)
- New App Intent (`NavigateCharacterIntent`) to handle previous/next navigation via interactive widget buttons (iOS 17+)
- Shared App Group container to pass pre-fetched character data (image + name) between the main app and the widget
- `CharacterWidgetEntry` timeline entry model (lightweight, `Codable`)
- `CharacterWidgetView` (SwiftUI) showing character image, name, and previous/next navigation arrows
- `CharacterWidgetProvider` (WidgetKit `TimelineProvider`) that reads from the shared App Group
- Main app populates the shared App Group with a snapshot of 20 randomly selected characters from the currently loaded pool when launched or refreshed
- `DIContainer` extended with an `AppGroupStore` to write character data to the shared container

**Non-goals**
- Showing episodes or locations in the widget (future scope)
- User-configurable character selection (IntentConfiguration — future scope)
- Making network calls directly from the widget (data is always pre-fetched by the main app)
- Configurable widget size families beyond `.systemSmall` and `.systemMedium` in this iteration
- Support for iOS versions below 17.0 (interactive widget buttons require iOS 17+)

## Capabilities

### New Capabilities

- `character-widget`: WidgetKit extension with interactive navigation — App Intent for previous/next, shared App Group data store, timeline provider, and SwiftUI widget view.

### Modified Capabilities

- `character-data-sharing`: The main app gains responsibility for writing a snapshot of character data (id, name, imageURL) to the shared App Group whenever the characters list is successfully loaded. This is an extension of the existing Data layer.

## Impact

**Affected layers**:
- **New target** — `CharacterWidgetExtension`: WidgetKit, App Intents, SwiftUI (widget views)
- **Core** — `DIContainer` and `AppGroupStore` (new shared data writer)
- **Data** — `CharactersListViewModel` triggers App Group write after successful load

**New dependencies**:
- `WidgetKit` framework (Apple, no SPM package needed)
- `AppIntents` framework (Apple, iOS 17+)
- App Group entitlement (`group.<bundle-id>.widget`)

**No changes to**:
- Domain layer (entities, use cases, repository protocols)
- Existing Presentation screens
- Network layer

**Test strategy**:
- Unit tests: `CharacterWidgetProvider` timeline generation logic, `AppGroupStore` read/write
- SwiftUI Previews: `CharacterWidgetView` for all states (loaded, empty, loading placeholder)
- Manual simulator verification: add widget to home screen, verify navigation arrows update character
- WidgetKit preview in Xcode: verify widget renders correctly in `.systemSmall` and `.systemMedium`
- XCUITest: not applicable for widget extension UI (WidgetKit previews cover this)
