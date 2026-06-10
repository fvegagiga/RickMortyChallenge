# Capability: Character Detail View

## Purpose

Defines the visual layout requirements for the Character Detail screen hero section, including the full-width bottom gradient overlay on the hero image that keeps the status badge and character name legible.

## Requirements

### Requirement: Full-width hero gradient overlay

The Character Detail hero section SHALL render a bottom gradient scrim that spans the full width of the hero image container to improve legibility of the status badge and character name.

#### Scenario: Gradient spans full hero width

- **WHEN** the Character Detail screen displays a character with a hero image
- **THEN** the bottom gradient overlay covers 100% of the hero section horizontal width

#### Scenario: Gradient preserves design dimensions

- **WHEN** the hero section is rendered at its standard height of 340 pt
- **THEN** the gradient scrim occupies approximately 160 pt at the bottom of the hero area with colors transitioning from `.black.opacity(0.7)` at the bottom to clear at the top

#### Scenario: Text remains bottom-leading aligned

- **WHEN** the gradient overlay is displayed
- **THEN** the status badge and character name remain bottom-leading aligned with `DSSpacing.md` padding and are legible over the gradient

### Requirement: Hero section layout independence from text width

The hero gradient overlay SHALL NOT be sized by the intrinsic width of the status badge or character name text.

#### Scenario: Long character name does not constrain gradient width

- **WHEN** a character has a long name that wraps or extends horizontally
- **THEN** the gradient scrim still spans the full hero section width regardless of text content width
