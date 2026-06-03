# Capability: Widget Index Counter

## Purpose

Displays the current character position within the total available characters in the widget navigation bar, formatted as "N / T" (e.g., "3 / 10"), so users always know where they are in the character list.

## Requirements

### Requirement: Widget displays character index counter
The system SHALL display the current character position within the total available characters in the format "N / T" (e.g., "3 / 10") inside the navigation bar.

#### Scenario: Multiple characters available
- **WHEN** the widget entry contains `totalCount > 1` and a valid `currentIndex`
- **THEN** the navigation bar shows a centered label formatted as "<currentIndex + 1> / <totalCount>"

#### Scenario: Single character available
- **WHEN** the widget entry contains `totalCount == 1`
- **THEN** the navigation bar shows "1 / 1"

#### Scenario: No characters available
- **WHEN** the widget is in placeholder state (`totalCount == 0` or no character data)
- **THEN** no index counter label is rendered

#### Scenario: Index counter visibility in systemSmall
- **WHEN** the widget is displayed in `.systemSmall`
- **THEN** the index counter is visible in the navigation bar between the previous and next buttons

#### Scenario: Index counter visibility in systemMedium
- **WHEN** the widget is displayed in `.systemMedium`
- **THEN** the index counter is visible in the navigation bar between the previous and next buttons
