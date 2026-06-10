## Context

The Character Detail screen (`CharacterDetailView`) displays a hero image with a bottom gradient overlay to improve legibility of the status badge and character name. The overlay is implemented in `CharacterDetailContentBodyView.heroSection` within `CharacterDetailView.swift`.

**Current behaviour:** The gradient is applied as a `.background()` on the text `VStack` inside `.overlay(alignment: .bottomLeading)`. SwiftUI sizes the `VStack` to its intrinsic content width, so the gradient background only spans that narrow width — not the full hero container.

**Reference implementation:** `CharacterWidgetView.smallLayout` already separates the full-width gradient layer from text content using a `ZStack` with `.frame(maxWidth: .infinity, …)`.

**Constraints:**
- Presentation-layer-only change; no ViewModel, use case, or repository modifications.
- Preserve hero height (340 pt), gradient height (~160 pt), colors, and design tokens (`DSSpacing`, `.DS.largeTitle`).
- Maintain existing screenshot test coverage via `testCharacterDetail_content`.

## Goals / Non-Goals

**Goals:**
- Make the bottom gradient scrim span 100% of the hero section width on all supported iPhone sizes.
- Keep status badge and character name bottom-leading aligned with existing padding.
- Align implementation with the widget's proven gradient layering pattern.

**Non-Goals:**
- Changing hero image height, info section layout, or typography.
- Introducing new design tokens or shared components (unless a trivial private helper within the same file).
- Modifying loading, error, or empty states.

## Decisions

### Decision 1: Use ZStack to decouple gradient from text (Option A)

**Choice:** Replace the single overlay with a `ZStack(alignment: .bottomLeading)` containing:
1. A full-width gradient layer: `LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top).frame(maxWidth: .infinity, height: 160, alignment: .bottom)`
2. The existing text `VStack` with `StatusBadgeView` and character name, padded with `DSSpacing.md`

**Rationale:** Matches the widget pattern (`CharacterWidgetView`) and explicitly controls gradient sizing independent of text intrinsic width.

**Alternative considered — Option B:** Add `.frame(maxWidth: .infinity, alignment: .leading)` to the padded `VStack` so its background expands. Rejected because it couples layout expansion to text container sizing and is less explicit than a dedicated gradient layer.

### Decision 2: Keep overlay on hero container, not ScrollView

**Choice:** Apply the refactored overlay on the hero `Group` (after `.frame(height: 340).clipped()`), preserving the current modifier order.

**Rationale:** Minimises diff scope; clipping behaviour remains unchanged.

### Decision 3: Update screenshot baseline, no new unit tests

**Choice:** Refresh `CharacterDetail_Content` baseline via existing screenshot test; skip new Swift Testing unit tests.

**Rationale:** Layout-only visual fix with no ViewModel or business logic changes. Screenshot regression is the appropriate verification mechanism per `ui-screenshot-regression-tests` spec.

## Risks / Trade-offs

- **[Risk] Gradient height misalignment on different screen widths** → Mitigation: Use fixed 160 pt height with full width; verify on iPhone 16 simulator and screenshot test.
- **[Risk] Text legibility regression on bright images** → Mitigation: Preserve existing gradient opacity (0.7) and colors; manual simulator check in light/dark mode.
- **[Risk] Unintentional snapshot diff in CI** → Mitigation: Regenerate and commit baseline only after confirming visual correctness locally.

## Migration Plan

1. Implement layout fix on feature branch.
2. Run screenshot test; update baseline if gradient width changes as expected.
3. Run full unit test suite (no Domain/Data impact expected).
4. Manual simulator verification on Character Detail.
5. Merge via PR; CI screenshot tests validate baseline.

**Rollback:** Revert the single-file SwiftUI change and restore previous screenshot baseline.

## Open Questions

None — root cause and fix approach are confirmed from code analysis.
