## Context

The Rick & Morty iOS challenge app has grown beyond its original README and architecture diagram. Key additions since the docs were written:

- **Network SPM package** — `NetworkService`, `RetryingNetworkService`, and `NetworkError` moved out of `Data/Network/`; only `APIEndpoint.swift` remains locally.
- **Widget extension** — `CharacterWidgetExtension` with App Intents, App Group storage (`AppGroupStore`), and shared image cache.
- **Expanded test suite** — Screenshot regression target, widget/storage unit tests, GitHub Actions CI.
- **Routing simplification** — `CharacterRoute` lives inside `AppRouter.swift`; no separate `AppRoute.swift` or location/episode routes.

The current `RickMortyArchitecture.drawio` has ~50 nodes and ~40 edges spanning 2200×1350 px, making it hard to parse. The user explicitly requested simplicity over completeness.

## Goals / Non-Goals

**Goals:**

- Bring `README.md` to full parity with the implemented app (features, structure, stack, tests, widget, CI).
- Replace the architecture diagram with a single-page, layer-based overview understandable in under 10 seconds.
- Keep all documentation in English per project standards.

**Non-Goals:**

- Code changes of any kind.
- Updating `docs/*.md` standards files.
- Adding screenshots or new documentation files.
- Documenting hypothetical/future features beyond the existing Scalability Examples section.

## Decisions

### 1. README structure: add Features section before Tech Stack

**Decision:** Insert a new **Features** section after Screenshots, before Tech Stack.

**Rationale:** The README currently jumps from screenshots to architecture without describing what the app does. A feature inventory helps interviewers and contributors immediately.

**Alternative considered:** Fold features into the Architecture section — rejected because features are user-facing, not structural.

### 2. README corrections as a checklist, not a rewrite

**Decision:** Preserve the existing README tone and sections (Key Technical Decisions, Scalability Examples, etc.) and surgically fix inaccuracies.

**Rationale:** The README is already well-written for a technical interview context. A full rewrite risks losing valuable decision rationale.

**Specific corrections:**

| Stale | Current |
|---|---|
| `AppRoute.swift` | `CharacterRoute` in `AppRouter.swift` |
| `Data/Network/NetworkService*.swift` | Network SPM v1.0.2; local `APIEndpoint.swift` only |
| `ContentView` | `MainTabView` |
| `AsyncCachedImage` | `CachedAsyncImageView` |
| iOS 16.0 | iOS 16.6 |
| Missing `Core/Storage/` | `AppGroupStore.swift`, `CharacterWidgetData.swift` |
| Missing targets | `CharacterWidgetExtension/`, `RickMortyChallengeScreenshotTests/` |
| Widget setup as manual steps | Note that targets are already configured in the Xcode project |

### 3. Architecture diagram: layer boxes with bullet lists, no edges

**Decision:** Redesign `RickMortyArchitecture.drawio` as a top-to-bottom (or left-to-right) stack of 4 coloured layer boxes plus 2 external system boxes, using text lists inside each box. Remove all inter-node edges and the legend.

**Rationale:** The user asked for "sencillo y fácil de entender de un vistazo". Layer boxes with grouped component names convey the same architectural story without the visual noise of 40 dependency arrows.

**Layout (top → bottom):**

```
┌─────────────────────────────────────────────┐
│  Presentation                                │
│  MainTabView · 3 tabs · ViewModels · Views  │
│  ViewState<T> · Shared Components           │
└─────────────────────────────────────────────┘
         ↓ depends on
┌─────────────────────────────────────────────┐
│  Domain                                      │
│  Entities · Repository Protocols · UseCases │
│  PagedResult<T>                              │
└─────────────────────────────────────────────┘
         ↓ implemented by
┌─────────────────────────────────────────────┐
│  Data                                        │
│  Repository Impls · DTOs · Mappers          │
│  APIEndpoint                                 │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  Core                                        │
│  DIContainer · AppRouter · DesignSystem     │
│  ImageCacheManager · AppGroupStore           │
└─────────────────────────────────────────────┘

External: [Rick & Morty API] ← Network SPM → [Data Layer]
External: [App Group Container] ← app ↔ widget
Extension: [CharacterWidgetExtension] — WidgetKit + AppIntents
```

**Canvas size:** ~900×700 px (fits one screen).

**Alternative considered:** Keep detailed class-level diagram with fewer nodes — rejected because even a trimmed version still requires edges to show DI and protocol conformance.

### 4. Draw.io format: replace XML content in place

**Decision:** Overwrite `RickMortyArchitecture.drawio` with a new minimal mxGraphModel XML, keeping the same filename and diagram name.

**Rationale:** No tooling dependency; the file remains openable in draw.io / diagrams.net.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Simplified diagram loses dependency-direction detail | README ASCII diagram and Layers Explained section retain the dependency narrative |
| README grows too long | Use concise bullet lists for Features; avoid duplicating content already in Key Technical Decisions |
| Draw.io XML hand-editing may render poorly | Open and verify in draw.io after writing; adjust geometry if needed during apply |
| Documentation drifts again after future features | `project-documentation` spec establishes maintenance requirements for future changes |

## Migration Plan

1. Create feature branch `feature/update-readme-and-architecture-diagram`.
2. Update `README.md` section by section (Features → corrections → new sections).
3. Replace `RickMortyArchitecture.drawio` with simplified layout.
4. Run `xcodebuild test` to confirm zero accidental code changes.
5. Manual review: diff README against codebase inventory checklist.

**Rollback:** `git checkout` the two files.

## Open Questions

None — scope and approach are clear from the user request and codebase audit.
