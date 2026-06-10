## Why

The Character Detail hero section renders a bottom gradient overlay to keep the status badge and character name legible over the image. Currently the gradient only spans the width of the text content instead of the full hero image, producing a visible UI defect (a narrow dark band floating over part of the image). This degrades polish and readability on the primary character browsing flow.

## What Changes

- Refactor the hero section overlay in `CharacterDetailView.swift` so the bottom gradient scrim spans the full width of the 340 pt hero area.
- Preserve existing gradient colors, height (~160 pt), text alignment (bottom-leading), and padding (`DSSpacing.md`).
- Update the `CharacterDetail_Content` screenshot baseline if the visual output changes as expected.
- No changes to ViewModels, use cases, repositories, networking, or navigation.

## Capabilities

### New Capabilities

- `character-detail-view`: Defines the visual layout requirements for the Character Detail screen hero section, including full-width bottom gradient overlay on the hero image.

### Modified Capabilities

<!-- No existing capability requirements change at the spec level. Screenshot baseline refresh is an implementation artifact covered by the existing `ui-screenshot-regression-tests` capability. -->

## Impact

- **Presentation layer**: `RickMortyChallenge/Presentation/Characters/Views/CharacterDetailView.swift` — `CharacterDetailContentBodyView.heroSection` overlay layout.
- **Screenshot tests**: `RickMortyChallengeScreenshotTests` — potential baseline update for `CharacterDetail_Content`.
- **No API, Domain, or Data layer changes.**
- **No breaking changes.**

## Non-goals

- Redesigning the info section, typography, or hero image height.
- Changing `CharacterDetailViewModel`, use cases, or repositories.
- Modifying the widget gradient overlay (already correct in `CharacterWidgetView`).
- Adding new navigation, accessibility identifiers, or loading/error state behaviour.

## Test Strategy

- **Unit tests**: Existing `CharacterDetailViewModelTests` must remain green; no new unit tests required (layout-only fix).
- **Screenshot regression**: Re-run `testCharacterDetail_content`; update baseline if the full-width gradient renders correctly.
- **Simulator verification**: Navigate Characters → tap a character; confirm full-width bottom gradient in light and dark mode on iPhone simulator.
- **XCUITest**: Not required — no user flow or interaction changes; existing `accessibilityIdentifier("character-detail")` unchanged.

## Affected Clean Architecture Layers

- **Presentation** (only)
