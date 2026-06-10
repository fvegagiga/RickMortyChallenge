# Specboot: Augmented Spec-driven development

![Specboot](https://drive.google.com/uc?export=view&id=1yic8hwSzSyQE6Zmf6__YNBcBvqiHMGEr)

Boot OpenSpec's Spec-Driven in any project and give superpowers to any coding agent.

This repository contains a comprehensive set of development rules, standards, and AI agent configurations designed to work seamlessly with multiple AI coding copilots. The setup is portable and can be imported into any project to provide consistent, high-quality AI-assisted development.

It's highly recommended to be used along with Spec-Driven Development frameworks like [OpenSpec](https://github.com/Fission-AI/OpenSpec)

## 📁 Repository Structure

```
.
├── docs/                            # Development standards and specifications (generic, role-based)
│   ├── project-profile.md           # This project's CONCRETE choices (filled by adapt-standards)
│   ├── domain-data-standards.md     # Clean Architecture: Domain & Data layers
│   ├── presentation-standards.md    # SwiftUI + MVVM Presentation layer
│   ├── advanced-topics.md           # Optional: SPM modularization, persistence, Swift 6
│   ├── documentation-standards.md   # Documentation structure and maintenance
│   ├── openspec-tasks-mandatory-steps.md  # Mandatory task structure for OpenSpec changes
│   ├── openspec-workflow.md         # OPSX slash commands and Specboot end-to-end flow
│   └── openspec-setup.md            # Prompt to configure openspec/config.yaml
├── ai-specs/
│   ├── agents/                      # Agent role definitions (domain-data, presentation, analyst)
│   └── skills/                      # Reusable skill prompts/workflows (incl. adapt-standards)
│
├── AGENTS.md                        # Generic agent configuration (core rules, single source of truth)
├── CLAUDE.md                        # Claude/Cursor-specific configuration
├── codex.md                         # GitHub Copilot/Codex configuration
└── GEMINI.md                        # Gemini-specific configuration
```

> The standards in `docs/` are **generic and role-based**: they describe principles and roles, not a
> specific stack. The concrete choices for your project live in `docs/project-profile.md`, produced
> by the `adapt-standards` skill (see step 3 below).

## 🤖 Multi-Copilot Support

This repository uses **symbolic links** or **naming conventions** to support multiple AI coding copilots without duplication:

- **`AGENTS.md`** → Generic agent rules (works with most copilots)
- **`CLAUDE.md`** → Optimized for Claude/Cursor
- **`codex.md`** → Optimized for GitHub Copilot/Codex
- **`GEMINI.md`** → Optimized for Google Gemini

All these files share the same core rules (kept identical across `AGENTS.md`, `CLAUDE.md`, `codex.md`, and `GEMINI.md`), ensuring consistency across different AI tools while allowing copilot-specific customizations.

### Why This Approach?

✅ **Single Source of Truth**: Core rules maintained in one place (`AGENTS.md`/`CLAUDE.md`)  
✅ **Copilot Compatibility**: Each AI tool finds its configuration using its preferred naming convention  
✅ **Zero Configuration**: Import into a new project and it works immediately  
✅ **Easy Updates**: Update rules once, all copilots benefit  
✅ **Portable**: Copy this structure to any project  

## 🚀 Quick Start

### 1) Install and Initialize OpenSpec

OpenSpec works great with this repository and is recommended for a spec-driven workflow.

Quick Start requirements from OpenSpec official docs:

- Node.js `20.19.0` or higher

Install OpenSpec globally:

```bash
npm install -g @fission-ai/openspec@latest
```

Then navigate to your project and initialize:

```bash
cd your-project
openspec init
```

Enable the **expanded OPSX workflow** (required for Specboot's iOS flow — `/opsx:ff`, `/opsx:verify`, …):

```bash
openspec config profile   # select expanded workflow commands
openspec update             # regenerate slash-command instructions in the project
```

See [OpenSpec Workflows](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md) and
`docs/openspec-workflow.md` for details.

### 2) Import Into Your Project

Copy this repository into your project first, so the `docs/` and `ai-specs/` paths already exist when you configure OpenSpec.

### 3) Adapt the Standards to Your Project (Mandatory)

This step is required. The standards in `docs/` are **generic and role-based** — they describe
principles and roles (a networking abstraction, a composition root, a navigation strategy, …)
rather than a fixed stack. To turn them into project-specific guidance, run the **`adapt-standards`
skill** as your **first task** after importing:

```text
Run the adapt-standards skill to adapt these standards to my project.
```

What it does:

- **Existing project**: scans your code and records the real choices (state management, DI,
  networking, navigation, persistence, design tokens, test framework) in `docs/project-profile.md`,
  and prunes standards sections that do not apply.
- **New project**: asks a short questionnaire and applies the recommended defaults
  (`@Observable`, Swift 6, constructor DI, native `NavigationStack`, Swift Testing, …) from
  `ai-specs/skills/adapt-standards/references/recommended-defaults.md`, then fills the profile.

After this, `docs/project-profile.md` is the single source of truth for your project's concrete
choices, and the generic standards resolve their roles against it. For optional manual tweaks, see
[Customization](#-customization).

### 4) Point OpenSpec Config to Your `docs/` and `ai-specs/`

After `openspec init`, after copying this repository, and after running `adapt-standards`, update
your project's `openspec/config.yaml` so its context references your standards, the project profile,
and the role agents.

The full, ready-to-use prompt and the expected `config.yaml` (iOS, Clean Architecture, referencing
`docs/project-profile.md` and the two role agents) live in **`docs/openspec-setup.md`** — follow it
to avoid maintaining two copies of the config.

## ✅ Verify Configuration (Required)

Do this after completing the setup steps above.

Your AI copilot should automatically load its config file (`CLAUDE.md` for Claude/Cursor, `codex.md`
for GitHub Copilot, `GEMINI.md` for Gemini), which shares the same core rules across tools. Verify
that:

- `docs/project-profile.md` exists and its axes are **Decided** (not all `TBD`).
- `openspec/config.yaml` context references the standards, `docs/project-profile.md`, and the two
  role agents.

All paths and rules are configured to work seamlessly without manual adjustments.

## 💡 Usage: OpenSpec + Specboot Workflow

OpenSpec now uses **OPSX** slash commands with the `/opsx:` prefix. Legacy commands (`/ff`,
`/apply`, `/new`, …) are deprecated.

Full command reference and migration table: **`docs/openspec-workflow.md`**.

### Recommended flow (expanded profile)

| Step | Command / skill | Role |
|---|---|---|
| 1 (once) | `adapt-standards` | Adapt generic standards to this project |
| 2 (optional) | `enrich-us` | Refine a vague user story or Jira ticket |
| 3 | `/opsx:new` → `/opsx:ff` | Create change + all planning artifacts |
| 4 | `/opsx:apply` | Implement `tasks.md` |
| 5 | `/opsx:verify` | Validate implementation vs artifacts |
| 6 | `adversarial-review` | Independent red-team review (Specboot) |
| 7 | `/opsx:archive` | Archive completed change (syncs specs if needed) |
| 8 | `commit` | Focused commits + PR (Specboot) |

Alternatives: `/opsx:propose` (faster, `core` profile), `/opsx:continue` (step-by-step planning),
`/opsx:explore` (investigation before planning). See `docs/openspec-workflow.md`.

Workflow reference image:

![OpenSpec custom workflow reference](https://drive.google.com/uc?export=view&id=1Bu8hysVBlpBZgH3SVgRh3knHS7W4X5ud)

### Optional: MCP Integrations (Jira + Playwright)

This workflow is enhanced with MCP servers that are mentioned in the workflow. These are optional and you can skip them entirely, or replace them with equivalent tools.

- **Jira MCP (recommended in `/enrich-us`)**: lets the agent read Jira tickets directly to enrich user stories without copy/paste.
- **Playwright MCP (recommended for E2E testing)**: lets the agent run browser-based E2E checks for user workflows.

Recommended installation approach:

- **Cursor**: enable/configure MCP servers in Cursor settings (add your Jira and Playwright MCP servers, then provide credentials such as Jira API tokens as required).
- **Other agents/IDEs**: follow your tool’s MCP installation docs and configure Jira/Playwright there.

If you don’t use Jira, or you don’t want automated E2E testing in this workflow, just update the skills and keep using the same OpenSpec command flow.

### Example: End-to-End Flow

Use these commands in sequence:

Optional first step (recommended): create a dedicated worktree before running the command flow, then clean it up when done. The `using-git-worktrees` skill can automate this.

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

Artifacts are managed through OpenSpec directories during this flow, including testing reports created. 

### Useful Skills

Skills live in `ai-specs/skills/` and are mirrored into `.claude/skills/` and `.cursor/skills/` via relative symlinks, so any copilot can discover them. The agent loads a skill automatically when a request matches its description (per `AGENTS.md` §4). The most useful ones in day-to-day work are **`enrich-us`**, **`using-git-worktrees`**, **`writing-skills`**, and **`code-auditing`**:

- **`enrich-us`** — Analyze and enhance a vague Jira user story (or raw idea) into an implementation-ready ticket with acceptance criteria, technical detail, and edge cases. Use **before** planning to make sure the team and the AI agree on scope.
- **`using-git-worktrees`** — Set up an isolated workspace before starting feature work or executing a plan, with safe creation, baseline checks, copying of local Claude settings, and a complete cleanup workflow when the work is done.
- **`writing-skills`** — Author and verify new skills (or refactor existing ones) following TDD-style validation before deployment. Use when adding a skill to `ai-specs/skills/` or editing an existing `SKILL.md`.
- **`code-auditing`** — Run a systematic 6-phase code quality audit covering security, performance, type safety, dead code, and library best practices, ending with a prioritized action plan. Use for pre-release reviews, technical-debt sweeps, and dependency audits.

Other active skills in this repository: `adapt-standards` (run first, after import), `commit`, `explain`, `meta-prompt`, `update-docs`. See each `ai-specs/skills/<name>/SKILL.md` for the full instructions.

## 📖 Core Development Rules

All development follows the core principles defined in `CLAUDE.md` / `AGENTS.md`:

### Key Principles

1. **Small Tasks, One at a Time**: Baby steps, never skip ahead
2. **Test-Driven Development (TDD)**: Write failing tests first
3. **Type Safety**: Fully typed Swift code
4. **Clear Naming**: Descriptive variables and functions
5. **English Only**: All code, comments, documentation, and messages in English
6. **90%+ Test Coverage**: Comprehensive testing across all layers
7. **Incremental Changes**: Focused, reviewable modifications

### Specific Standards

- **Project Profile**: `docs/project-profile.md`
  - This project's concrete choices for every role (the standards below are generic)
- **Domain & Data Standards**: `docs/domain-data-standards.md`
  - Clean Architecture, entities, repository protocols, use cases
  - DTOs, mappers, networking abstraction, dependency injection
  - Unit testing (Swift Testing / XCTest)
- **Presentation Standards**: `docs/presentation-standards.md`
  - SwiftUI + MVVM, `ViewState`, navigation strategy
  - Design system tokens, reusable components, XCUITest
- **Advanced & Optional Topics**: `docs/advanced-topics.md`
  - SPM modularization, local persistence, Swift 6 strict concurrency
- **Documentation Standards**: `docs/documentation-standards.md`
  - Technical documentation structure and maintenance guidelines

## 🎯 Benefits

### For Developers

- ✅ **Consistent Code Quality**: AI follows the same standards every time
- ✅ **Comprehensive Testing**: Automatic 90%+ coverage across all layers
- ✅ **Complete Documentation**: API specs updated automatically
- ✅ **Faster Onboarding**: New team members reference the same rules
- ✅ **Reduced Review Time**: Code follows established patterns

### For Teams

- ✅ **Copilot Flexibility**: Team members can use their preferred AI tool
- ✅ **Knowledge Preservation**: Standards documented, not in people's heads
- ✅ **Quality Consistency**: Same standards regardless of who (or what) writes code
- ✅ **Easier Code Reviews**: Clear expectations and patterns
- ✅ **Scalable Practices**: Standards scale with the team

### For Projects

- ✅ **Maintainable Codebase**: Clean architecture and clear separation of concerns
- ✅ **Production-Ready Code**: TDD, error handling, and validation built-in
- ✅ **Living Documentation**: API specs and data models always current
- ✅ **Faster Feature Development**: Autonomous AI implementation from plans
- ✅ **Lower Technical Debt**: Best practices enforced from day one

## 🔧 Customization

### Adapting to Your Project

1. **Update technical context**: Find the different files in `docs` and modify core principles, coding standards, business rules and technical documentation to match your needs:
  - backend/frontend/testing/documentation standards
  - installation guide
  - data model
  - API docs
  - ...
2. **Adapt agents in `ai-specs/agents`**: Adjust agent definitions to your project's roles and workflows
3. **Extend skills in `ai-specs/skills`**: Define battle-tested prompts and workflows in reusable skills
4. **Link Resources**: Reference your project's specific documentation or tasks using MCPs
5. **Keep the symlink structure**: Remember to create relative symlinks from `.claude` and `.cursor` to the corresponding `ai-specs/agents` and `ai-specs/skills` entries to keep it consistent

### Prompt Example: Adapt Technical Context

The primary, recommended path is to run the **`adapt-standards`** skill (step 3 above), which fills
`docs/project-profile.md` and prunes non-applicable sections automatically. Use the manual prompt
below only for additional, project-specific tweaks beyond what the skill resolves:

```text
Using docs/project-profile.md as the source of truth for concrete choices, refine the docs/ for this project's specifics.

Requirements:
- Do NOT re-genericize the standards; they intentionally describe roles. Concrete choices belong in docs/project-profile.md.
- Fill any remaining TBD axes in docs/project-profile.md (deployment target, state management, DI, networking, navigation, persistence, design tokens, test framework) and the concrete-name glossary.
- Add docs/data-model.md and docs/api-spec.yml only if the app has a domain model / consumes an API; keep them consistent with the profile.
- Ensure all references are internally consistent and aligned across docs/ and the two agents in ai-specs/agents/.
- Keep everything in English and make guidance implementation-ready for AI agents.
```

### Maintaining Standards

- **Single Source of Truth**: Update core rules in `CLAUDE.md` / `AGENTS.md`; keep project-specific choices in `docs/project-profile.md`
- **Version Control**: Track changes to standards like code
- **Team Review**: Standards changes should be reviewed like pull requests
- **Documentation**: Keep examples current with actual implementation
- **Symlink Integrity**: After file renames/moves/suffix changes, verify and update all impacted symlinks
- **Canonical Placement**: Prefer `ai-specs` as canonical source and expose through symlinks for `.claude`/`.cursor` compatibility

## 📚 Technical context

### Optional Project Documents

These documents are **not included by default** — create them only when your project needs them,
tailored to your domain. Once created, reference them from `docs/project-profile.md` and the
OpenSpec config:

- **API Specification**: `docs/api-spec.yml` (OpenAPI 3.0 format)
  - *Create only if the app consumes a documented REST API*
- **Data Models**: `docs/data-model.md` (domain entities, persistence schema)
  - *Document your domain entities and any local persistence model*

## 🤝 Contributing

When contributing to the standards:

1. Update core rules in `CLAUDE.md` / `AGENTS.md` (single source of truth); keep project-specific choices in `docs/project-profile.md`
2. Keep the standards generic and role-based — concrete stack decisions belong in the profile, not the standards
3. Test with multiple AI copilots to ensure compatibility
4. Document breaking changes clearly
5. Follow the same standards you're defining!

## 📄 License

Licensed under the MIT License

---

## 🙏 Acknowledgements

Some workflows and skill patterns in this repository are inspired by the Superpowers framework, especially around:

- `using-git-worktrees`
- `writing-skills`

Superpowers project: [obra/superpowers](https://github.com/obra/superpowers/tree/main)

Additional inspiration/source acknowledgements:

- `code-auditing` skill: inspired by and adapted from [jeffrigby/somepulp-agents](https://github.com/jeffrigby/somepulp-agents/tree/main)