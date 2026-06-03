## ADDED Requirements

### Requirement: Widget displays current character
The system SHALL render a home screen widget showing the currently selected character's image and name, read from the shared App Group storage.

#### Scenario: Character data available
- **WHEN** the widget is rendered and shared storage contains at least one character
- **THEN** the widget displays the character's image and name for the current index

#### Scenario: No data available
- **WHEN** the widget is rendered and shared storage is empty or uninitialized
- **THEN** the widget displays a placeholder state (app icon or generic silhouette with "Open app to load characters")

#### Scenario: Image file missing for current character
- **WHEN** the widget renders a character whose image file is not found in the shared container
- **THEN** the widget displays the character's name with a placeholder image (grey rectangle)

---

### Requirement: Widget supports previous and next navigation
The system SHALL provide interactive previous (←) and next (→) navigation buttons that cycle through the available characters in the shared snapshot.

#### Scenario: User taps next arrow
- **WHEN** the user taps the next (→) button on the widget
- **THEN** the current index increments by 1, wrapping to 0 when it exceeds the last character
- **AND** the widget reloads and displays the new character

#### Scenario: User taps previous arrow
- **WHEN** the user taps the previous (←) button on the widget
- **THEN** the current index decrements by 1, wrapping to the last character when it goes below 0
- **AND** the widget reloads and displays the new character

#### Scenario: Navigation with single character in snapshot
- **WHEN** the snapshot contains exactly one character and the user taps next or previous
- **THEN** the widget stays on the same character (no visible change)

---

### Requirement: Widget supports systemSmall and systemMedium families
The system SHALL render correctly in both `.systemSmall` and `.systemMedium` widget sizes.

#### Scenario: systemSmall layout
- **WHEN** the widget is displayed in `.systemSmall`
- **THEN** the character image fills most of the widget area with the name overlaid at the bottom, and the navigation arrows are visible

#### Scenario: systemMedium layout
- **WHEN** the widget is displayed in `.systemMedium`
- **THEN** the character image is shown on the left half, and the name plus navigation arrows are on the right half

---

### Requirement: Widget navigation state persists between renders
The system SHALL persist the current character index in the shared App Group so that navigation state survives widget reloads and device restarts.

#### Scenario: Widget reloads after timeline refresh
- **WHEN** WidgetKit reloads the widget timeline
- **THEN** the widget displays the same character that was shown before the reload

#### Scenario: App is relaunched after widget navigation
- **WHEN** the user opens the main app after navigating via the widget
- **THEN** the app is unaffected by the widget's current index (app state is independent)
