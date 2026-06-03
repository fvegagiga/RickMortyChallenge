## MODIFIED Requirements

### Requirement: Widget displays current character
The system SHALL render a home screen widget showing the currently selected character's image, name, and status indicator, read from the shared App Group storage. All typography and color tokens SHALL come from the project's design system (`DSTypography`, `DSColors`, `DSSpacing`).

#### Scenario: Character data available
- **WHEN** the widget is rendered and shared storage contains at least one character
- **THEN** the widget displays the character's image, name, and status dot for the current index

#### Scenario: No data available
- **WHEN** the widget is rendered and shared storage is empty or uninitialized
- **THEN** the widget displays a placeholder state with a `person.fill` SF Symbol icon and the text "Open the app to load characters"

#### Scenario: Image file missing for current character
- **WHEN** the widget renders a character whose image file is not found in the shared container
- **THEN** the widget displays the character's name and status dot with a grey placeholder rectangle

---

### Requirement: Widget supports systemSmall and systemMedium families
The system SHALL render correctly in both `.systemSmall` and `.systemMedium` widget sizes using design system spacing and color tokens. Content margins SHALL be disabled so the image fills the widget edge to edge with no system-imposed white borders.

#### Scenario: systemSmall layout
- **WHEN** the widget is displayed in `.systemSmall`
- **THEN** the character image fills the entire widget edge to edge, a gradient overlay covers the bottom half, and the name, status dot, and navigation bar (index counter and portal-green chevrons) are overlaid on the gradient at the bottom

#### Scenario: systemMedium layout
- **WHEN** the widget is displayed in `.systemMedium`
- **THEN** the character image fills the left side at its natural 1:1 aspect ratio (height = widget height), the gradient overlay and name/status dot/navigation bar are overlaid at the bottom of the image area, and the right side remains empty (shows the widget background)
