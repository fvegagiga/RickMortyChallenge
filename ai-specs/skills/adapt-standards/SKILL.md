---
name: adapt-standards
description: Adapt the generic iOS Swift/SwiftUI standards to a specific project. Run as the FIRST task after importing these standards into a project. Detects new vs existing codebase, fills docs/project-profile.md (scanning real code or applying recommended defaults), and prunes standards sections that do not apply.
author: Fernando Vega
version: 1.1.0
---

# adapt-standards Skill

The standards in `docs/domain-data-standards.md`, `docs/presentation-standards.md`, and
`docs/advanced-topics.md` are written generically, in terms of **principles and roles**. This skill
turns them into project-specific guidance by resolving every role to a concrete choice in
**`docs/project-profile.md`**.

**Run this skill as the first task after importing Specboot into a project**, before using the
OpenSpec workflow (`/opsx:ff`, `/opsx:apply`, …). It is safe to re-run: it updates the profile rather than
duplicating it.

## When to use

- Right after copying these standards into a new or existing iOS project.
- When the project's architecture changes in a way that invalidates `docs/project-profile.md`
  (e.g. migrating `ObservableObject` → `@Observable`, adopting SwiftData, splitting into SPM
  modules).

## Workflow

### Step 1 — Detect the project mode

Determine whether this is an **existing** or **new** project:

- **Existing project**: there is real Swift source (an `.xcodeproj`/`.xcworkspace`, a
  `Package.swift` with targets, or `*.swift` files beyond the templates).
- **New project**: only the imported standards/templates are present, with little or no Swift
  source yet.

If ambiguous, ask the user which mode to use.

### Step 2a — Existing project: analyze and record

Scan the codebase to discover what is **actually** used, then fill in `docs/project-profile.md`.
Resolve each axis from evidence, not assumption:

| Axis | What to look for |
|---|---|
| Deployment target / Swift mode | `IPHONEOS_DEPLOYMENT_TARGET`, `swift-tools-version`, `SWIFT_VERSION`, `SWIFT_STRICT_CONCURRENCY` |
| Package management | `Package.swift` + `Package.resolved`, `XCRemoteSwiftPackageReference` in the `.pbxproj`, a `Podfile`/`Podfile.lock`, or a `Cartfile` — do not infer SPM from a single `import` |
| State management | `@Observable` + `import Observation` vs `ObservableObject` + `@Published` |
| Composition root / DI | a container type, `@Environment(...)`, or a DI library (Factory, Swinject, Resolver) |
| Navigation strategy | a SwiftUI router/coordinator type, `NavigationStack(path:)`, `NavigationPath`, a UIKit `UINavigationController`-based Coordinator (`import UIKit`), or TCA |
| Networking | `URLSession`, Alamofire, a `*NetworkService` protocol, or none |
| Endpoint catalog | an `APIEndpoint`-style enum or request builder |
| Pagination | a `PagedResult`-style type or paginated responses |
| Image caching | a cached image view / cache manager, or only `AsyncImage`/assets |
| Persistence | SwiftData (`@Model`), Core Data (`NSManagedObject`), Keychain, `UserDefaults`, none |
| Module layout | single target vs multiple SPM packages |
| Test framework | `import Testing` (`@Test`) vs `XCTest`; `XCUITest` for UI. If a test target exists but has **no test sources yet**, record the recommended default and mark it **TBD** (no evidence to prove a choice) |
| Concrete names | the real symbol names for each role (for the glossary in §5 of the profile) |

> **Mixed-paradigm codebases**: real apps often combine paradigms (e.g. SwiftUI views with a UIKit
> navigation coordinator, or `@Observable` ViewModels alongside legacy `ObservableObject` ones).
> Record what each layer actually uses; if a paradigm is being migrated, note the target state and
> mark the axis Decided for the dominant/intended approach.

Then:

1. Update every table in `docs/project-profile.md`: set the concrete value and mark **Decided**.
2. Fill the **Concrete Type Names** glossary (§5) with the project's real symbols.
3. List roles that genuinely do not exist under **Excluded Roles** (§7) and mark them **N/A**.
4. Fill the **Domain Context** (§6).

### Step 2b — New project: choose defaults via questionnaire

There is no code to analyze, so apply the **recommended defaults** in
`references/recommended-defaults.md`, after asking only the questions that genuinely branch the
setup. Ask a short, focused questionnaire:

1. Minimum iOS deployment target? (drives `@Observable` vs `ObservableObject`; also note that Swift
   6 vs Swift 5 + Strict Concurrency can additionally depend on whether mandated dependencies
   support Swift 6 — see question 5)
2. Does the app consume a remote API? (remote / local-only / hybrid)
3. Does the app store data locally? If so, what kind? (structured model / secrets / preferences)
4. Single app target or modularized (SPM) from the start?
5. Any mandated third-party libraries (networking, DI, navigation)? Otherwise use defaults.
6. If it consumes an API: do endpoints paginate, and does the UI load remote images? (resolves the
   pagination and remote-image-caching axes)

Use the answers + defaults to fill `docs/project-profile.md`, marking chosen values **Decided** and
anything left to the default as **TBD** (default applies provisionally). Mark non-applicable roles
**N/A**.

Two axes are commonly unknowable at greenfield time and may legitimately stay **TBD** until the
detail exists, rather than being forced:

- **Pagination / remote image caching** when the API contract is not yet defined (even after
  question 6, if the answer is "don't know yet").
- **Domain Context** (§6 of the profile): app purpose and primary entities. Ask the user if they
  can describe them; otherwise leave **TBD** with a note to fill it once the domain is defined. Do
  not invent entities.

### Step 3 — Prune the generic standards

Using the resolved profile, remove or clearly neutralize the sections that do not apply, so the
standards no longer prescribe abstractions the project will never use. Examples:

- No remote API → remove Networking / DTOs / Mappers / endpoint-catalog guidance and the image
  caching role.
- Asset-only UI → remove the cached image component guidance.
- No pagination → remove the paginated-result guidance.
- `ObservableObject` chosen → keep Option B examples; clearly mark Option A as not used (or vice
  versa).

**How to prune** — prefer **neutralize-in-place** over deletion: replace the body of a
non-applicable section with a short "N/A for this project — see `docs/project-profile.md`" note,
keeping the heading so the table of contents and cross-references stay intact and the choice is
reversible. Reserve full deletion for cases where the user explicitly wants the standards trimmed.
This applies equally to `docs/advanced-topics.md` (which is `alwaysApply: false`).

**Comparative tables are intentionally retained.** When the project chooses one option of a pair
(e.g. `@Observable` over `ObservableObject`), keep the comparison/mapping tables that mention both —
mark the chosen option as binding and the other as "not used / migration reference", but do **not**
delete the comparative content. It documents how to read the rest of the guide.

Do **not** weaken the always-apply core: Clean Architecture and the dependency rule, type safety,
`async/await`, `Sendable`, naming, error handling, and testing discipline.

### Step 4 — Reconcile downstream artifacts

- Ensure the two role agents (`ai-specs/agents/domain-data-developer.md`,
  `ai-specs/agents/presentation-developer.md`) read against the resolved profile (they reference
  `docs/project-profile.md` for concrete names).
- If the project uses OpenSpec, ensure `openspec/config.yaml` context references
  `docs/project-profile.md` alongside the standards (see `docs/openspec-setup.md`).

### Step 5 — Report

Produce a concise report:

- Detected mode (new / existing).
- The resolved value for each axis, and which were **Decided** vs left at **TBD** vs **N/A**.
- Which standards sections were pruned.
- Any axis that needs a human decision (list them explicitly).

## Red flags

Never:
- invent a project's choice without evidence (existing) or without asking the branching questions (new);
- prune the always-apply architectural core;
- leave `docs/project-profile.md` with `TBD` for an axis you had clear evidence for.

Always:
- keep `docs/project-profile.md` as the single source of concrete choices;
- prefer the recommended defaults for new projects unless the user overrides them;
- re-run safely (update in place, never duplicate the profile).
