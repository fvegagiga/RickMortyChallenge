# Capability: Widget Character Status Indicator

## Purpose

Displays a color-coded status dot next to the character name in the WidgetKit widget, using the project's design system status colors to indicate whether a character is Alive, Dead, or Unknown.

## Requirements

### Requirement: Widget displays character status indicator
The system SHALL render a color-coded status dot next to the character name using the project's design system status colors.

#### Scenario: Character status is Alive
- **WHEN** the widget renders a character whose `status` field equals "Alive"
- **THEN** the status dot is rendered using `Color.DS.statusAlive` (green)

#### Scenario: Character status is Dead
- **WHEN** the widget renders a character whose `status` field equals "Dead"
- **THEN** the status dot is rendered using `Color.DS.statusDead` (red)

#### Scenario: Character status is Unknown or empty
- **WHEN** the widget renders a character whose `status` field is "unknown", empty, or any unrecognized value
- **THEN** the status dot is rendered using `Color.DS.statusUnknown` (grey)

#### Scenario: No character loaded
- **WHEN** the widget is in placeholder state (no character data)
- **THEN** no status dot is rendered
