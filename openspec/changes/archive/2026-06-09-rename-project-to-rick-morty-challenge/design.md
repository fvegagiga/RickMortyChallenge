## Context

`RickMortyPersistImage` is the legacy name embedded across the entire repository: directory
names, the `.xcodeproj`, the `project.pbxproj` (~93 references), four targets, shared schemes,
the test plan, entitlements (App Group), bundle identifiers, the SwiftUI `App` struct, every
`@testable import`, the CI workflow, live documentation, and the architecture diagram. The
rename to `RickMortyChallenge` is a pure refactor with no behavioral change, but it is
cross-cutting and touches code-signing-sensitive identifiers, so it benefits from an explicit
plan and an ordered, verifiable migration.

Constraints:
- All technical artifacts must be in English (project rule).
- Work in small, verifiable steps (TDD/incremental principle).
- Historical OpenSpec archives are immutable records.
- The Widget extension shares data with the app via an App Group; renaming the App Group must
  keep both sides in sync to avoid breaking data sharing.

## Goals / Non-Goals

**Goals:**
- Replace every live reference to `RickMortyPersistImage` with `RickMortyChallenge`.
- Keep the project buildable and all tests green at the end of the migration.
- Preserve git history of moved files where practical (use `git mv` for directory renames).
- Keep the rename mechanical and behavior-preserving.

**Non-Goals:**
- Changing the Widget extension's own feature name (`CharacterWidgetExtension`).
- Editing archived OpenSpec changes/reports under `openspec/changes/archive/**`.
- Any functional, UI, or API behavior change.

## Decisions

### Decision 1: Rename strategy — manual, ordered edits over a blind find/replace
Xcode project structure is fragile; a blanket text replace can corrupt the `.pbxproj` or leave
the on-disk directory names out of sync with `path`/`name` references. We will rename in a
controlled order: (1) on-disk directories and files via `git mv`, (2) `.pbxproj` `path`/`name`/
`productName`/build-setting references, (3) schemes and test plan, (4) source/entitlements,
(5) CI and docs. After the structural rename we run a final repository-wide search (excluding
`openspec/changes/archive/**`) to confirm zero remaining references.
- *Alternative considered*: scripted `sed` over all files. Rejected as the primary tool because
  it risks silent `.pbxproj` corruption and renames archived history; it may be used only for
  bulk, low-risk text files (e.g. docs) with review.

### Decision 2: Rename bundle identifiers and App Group
The user requires all references changed, and identifiers carry the legacy name. We rename
`com.fvg0902iosdev.RickMortyPersistImage*` → `com.fvg0902iosdev.RickMortyChallenge*` and the
App Group `group.com.fvg0902iosdev.RickMortyPersistImage.widget` →
`group.com.fvg0902iosdev.RickMortyChallenge.widget` in the three entitlements files and in
`AppGroupStore.appGroupIdentifier`.
- *Alternative considered*: keep identifiers to avoid re-provisioning. Rejected because it would
  leave the legacy name in live artifacts, contradicting the goal.

### Decision 3: Module name follows the app target name
Renaming the app target to `RickMortyChallenge` changes the Swift module name, so every
`@testable import RickMortyPersistImage` becomes `@testable import RickMortyChallenge`, and the
`RickMortyPersistImageApp` struct/file is renamed to `RickMortyChallengeApp`.

### Decision 4: Preserve archived history
Archived OpenSpec artifacts and reports stay untouched; the "no live references" check
explicitly excludes `openspec/changes/archive/**`.

## Risks / Trade-offs

- **App Group / bundle identifier re-provisioning** → With automatic signing, new identifiers
  are created on demand for development; we verify on the simulator that widget data sharing
  still works. If signing fails, fall back to confirming the App Group capability is enabled in
  the target settings.
- **`.pbxproj` corruption from edits** → Make edits in small chunks, keep a clean git checkpoint
  before structural changes, and verify by opening/building the project after each major step.
- **Stale DerivedData referencing old product names** → Clean build (and DerivedData if needed)
  before the final verification run.
- **Lost git blame on renamed directories** → Use `git mv` so renames are tracked as moves.
- **Missed references** → Final repo-wide grep (excluding archives) is the completion gate.

## Migration Plan

1. Create the feature branch and a clean checkpoint commit.
2. `git mv` the four target directories, the `.xcodeproj` bundle, the test plan, and the
   entitlements files to their new names.
3. Update `project.pbxproj` references (paths, names, productName, bundle IDs, TEST_HOST,
   TEST_TARGET_NAME) and rename the scheme files plus their internal references.
4. Rename the `App` struct/file and update all `@testable import` statements and the App Group
   identifier in entitlements and `AppGroupStore`.
5. Update the CI workflow, live docs, and the architecture diagram.
6. Clean build, then run unit, screenshot, and UI test schemes; verify widget data sharing on
   the simulator.
7. Run the final repo-wide search (excluding archives) to confirm no legacy references remain.

**Rollback**: revert the feature branch; no data migration is involved.

## Open Questions

- None. App Group and bundle identifier renames are confirmed in scope per the request.
