---
description: Specboot workflow on top of OpenSpec OPSX slash commands — setup, command reference, and the recommended iOS end-to-end flow.
alwaysApply: false
---

# OpenSpec Workflow (Specboot)

OpenSpec ([Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)) now uses **OPSX** slash commands
with the `/opsx:` prefix. Legacy commands without the prefix (`/ff`, `/apply`, `/new`, …) are
**deprecated** — use the mappings below.

Official references:
- [Commands](https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md)
- [Workflows](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md)

## Setup (once per project)

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init
```

**Enable the expanded workflow** (required for Specboot's iOS flow — includes `/opsx:ff`,
`/opsx:verify`, `/opsx:continue`, …):

```bash
openspec config profile   # select expanded workflow commands
openspec update             # regenerate slash-command instructions in the project
```

After upgrading the global OpenSpec package, re-run `openspec update` inside each project.

Before the first change, run the **`adapt-standards`** skill so `docs/project-profile.md` is
filled in. See `docs/openspec-setup.md` for `openspec/config.yaml` context.

## Two OpenSpec profiles

| Profile | Default? | Planning | Typical flow |
|---|---|---|---|
| **`core`** | Yes (new installs) | `/opsx:propose` creates all planning artifacts in one step | `propose → apply → sync → archive` |
| **Expanded** | Opt-in via `openspec config profile` | `/opsx:new` + `/opsx:ff` or `/opsx:continue` | `new → ff → apply → verify → archive` |

**Specboot recommends the expanded profile** because the iOS workflow relies on:
- `/opsx:verify` before archiving
- `/opsx:ff` or `/opsx:continue` with `docs/openspec-tasks-mandatory-steps.md` (xcodebuild, simulator, XCUITest)
- Step-by-step control when requirements need refinement

You may still use `/opsx:propose` for small, well-understood changes if you accept that planning is
less granular.

## Command reference

### OpenSpec commands (`/opsx:*`)

| Command | Purpose | When to use (Specboot) |
|---|---|---|
| `/opsx:propose [name]` | Create change + all planning artifacts at once | Quick path (`core` profile); small/clear scope |
| `/opsx:explore [topic]` | Investigate without creating artifacts | Unclear requirements, architecture spikes |
| `/opsx:new [name]` | Scaffold a change folder only | Expanded profile; start of structured planning |
| `/opsx:continue [name]` | Create the next artifact one at a time | Exploratory planning, review each artifact |
| `/opsx:ff [name]` | Fast-forward: all planning artifacts | **Default Specboot planning step** when scope is clear |
| `/opsx:apply [name]` | Implement `tasks.md` | After planning artifacts exist |
| `/opsx:verify [name]` | Validate implementation vs artifacts | **Mandatory in Specboot flow** before archive |
| `/opsx:sync [name]` | Merge delta specs into `openspec/specs/` | When archive prompts for spec sync |
| `/opsx:archive [name]` | Complete and archive the change | After verify (+ adversarial-review) |
| `/opsx:bulk-archive` | Archive multiple completed changes | Parallel work streams |
| `/opsx:onboard` | Guided tutorial | First-time OpenSpec in a project |

### Specboot extensions (skills — not OpenSpec commands)

| Skill / step | Purpose | When |
|---|---|---|
| `adapt-standards` | Fill `docs/project-profile.md`, prune standards | **First run** after importing Specboot |
| `enrich-us` | Refine a vague user story / Jira ticket | Optional, **before** planning |
| `using-git-worktrees` | Isolated workspace per change | Optional, before planning |
| `adversarial-review` | Independent red-team review | **After** `/opsx:verify`, before archive |
| `commit` | Focused commits + PR | After archive |

## Specboot recommended end-to-end flow

```text
adapt-standards (once)
    ↓
[optional] enrich-us ──► [optional] using-git-worktrees
    ↓
/opsx:new <change> ──► /opsx:ff <change>     # or /opsx:continue for exploratory planning
    ↓                                          # or /opsx:propose <change> on core profile
/opsx:apply <change>
    ↓
/opsx:verify <change>
    ↓
adversarial-review <change>
    ↓
/opsx:archive <change>    # syncs specs if prompted
    ↓
commit
```

**Example sequence** (expanded profile):

```text
/enrich-us SCRUM-10
/opsx:new add-product-detail
/opsx:ff add-product-detail
/opsx:apply add-product-detail
/opsx:verify add-product-detail
/adversarial-review add-product-detail
/opsx:archive add-product-detail
/commit
```

For exploratory work, replace `/opsx:ff` with `/opsx:continue` (or start with `/opsx:explore`).

## Planning: which command?

| Situation | Use |
|---|---|
| Clear scope, want Specboot mandatory `tasks.md` structure | `/opsx:new` → `/opsx:ff` |
| Figuring out scope artifact by artifact | `/opsx:new` → `/opsx:continue` |
| Smallest number of steps, simple change | `/opsx:propose` |
| Requirements unclear, need investigation | `/opsx:explore` → then planning command |

All planning paths must produce `tasks.md` that follows `docs/openspec-tasks-mandatory-steps.md`.

## Post-apply changes (between apply and archive)

If a new requirement appears after `/opsx:apply` and before `/opsx:archive`, **update OpenSpec
artifacts first** (scenarios, specs, `tasks.md`) — do not apply informal code-only fixes. Then:

1. Edit artifacts, or run `/opsx:continue` / `/opsx:ff` to regenerate if needed
2. Resume `/opsx:apply`
3. Re-run `/opsx:verify` and `adversarial-review`

See `CLAUDE.md` §7.

## Migration from legacy commands

| Legacy (deprecated) | Replacement |
|---|---|
| `/new` | `/opsx:new` |
| `/ff` | `/opsx:ff` or `/opsx:propose` |
| `/propose` | `/opsx:propose` |
| `/apply` | `/opsx:apply` |
| `/verify` | `/opsx:verify` |
| `/archive` | `/opsx:archive` |
| `openspec-ff-change` (skill name) | `/opsx:ff` |
| `openspec-continue-change` (skill name) | `/opsx:continue` |
| `openspec-apply-change` (skill name) | `/opsx:apply` |

Specboot-only steps (`enrich-us`, `adversarial-review`, `commit`) are unchanged — they are project
skills, not OpenSpec slash commands.

## Upgrading OpenSpec

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec update
```

Re-run `openspec config profile` if expanded commands disappear after an upgrade.
