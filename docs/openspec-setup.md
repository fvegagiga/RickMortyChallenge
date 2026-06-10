---
description: Prompt and reference example to configure openspec/config.yaml for this iOS Swift/SwiftUI project using Clean Architecture.
alwaysApply: false
---

# OpenSpec Config Setup

Use the prompt below with your AI copilot to populate `openspec/config.yaml` with the correct technical context for this project.

> **Run `adapt-standards` first.** Before configuring OpenSpec, run the `adapt-standards` skill so
> `docs/project-profile.md` records this project's concrete choices (state management, DI,
> networking, navigation, persistence, design tokens, test framework). The standards in `docs/` are
> generic and reference that profile for concrete decisions.

---

## Prompt

```
Update my openspec/config.yaml context to reference this project's docs and ai-specs structure.

Requirements:
- Use CLAUDE.md as the single source of truth for core principles, language standards, and project-wide rules.
- Include docs/project-profile.md as the source of truth for this project's CONCRETE choices (state management, DI, networking, navigation, persistence, design tokens, deployment target, test framework). The standards docs are generic and reference it.
- Include docs/domain-data-standards.md for Domain and Data layer work (Clean Architecture, Swift, async/await, repositories, use cases).
- Include docs/presentation-standards.md for Presentation layer work (SwiftUI, MVVM, ViewState, design system, navigation, XCUITest).
- Include docs/advanced-topics.md for optional topics (SPM modularization, local persistence, Swift 6 strict concurrency) — apply only when the project needs them.
- Include docs/documentation-standards.md for documentation rules.
- Include docs/openspec-tasks-mandatory-steps.md for mandatory task structure (xcodebuild test, simulator verification, XCUITest).
- Tell the agent to adopt ai-specs/agents/domain-data-developer.md for Domain and Data layer work, and ai-specs/agents/presentation-developer.md for Presentation layer work.
- Mention ai-specs/skills as workflow guidance, and that adapt-standards must be run before the first change.
- Reference docs/openspec-workflow.md for OPSX slash commands (`/opsx:*`) and the Specboot end-to-end flow.
- Keep all paths relative to the project root.
- Set the tech stack, architecture, and domain context for this specific project from docs/project-profile.md (iOS, Swift, SwiftUI, Clean Architecture, <your REST API / domain>).
```

---

## Expected Result

After running the prompt above, `openspec/config.yaml` should look like this:

```yaml
schema: spec-driven

context: |
  Tech stack: Swift, SwiftUI, Combine, async/await, XCTest, Swift Package Manager
  Architecture: Clean Architecture with Domain, Data, Core, and Presentation layers
  Dependency rule: Domain has zero dependencies on Data, Core, or UI frameworks
  We use conventional commits in English
  Domain: iOS app consuming a REST API (<api-base-url>)
    — <FeatureA>, <FeatureB>, <FeatureC> with pagination and image caching
  All code, comments, documentation, and technical artifacts must be in English

  Project specs (single source of truth): All artifact creation and implementation
  MUST follow the project's technical context. Read and apply these when creating
  or implementing:
  - CLAUDE.md — core principles, TDD, language standards, OpenSpec workflow rules
  - docs/project-profile.md — this project's CONCRETE choices (state management, DI,
    networking, navigation, persistence, design tokens, deployment target, test
    framework); the standards below are generic and resolve their "roles" here
  - docs/domain-data-standards.md — Clean Architecture, entities, repository protocols,
    use cases, DTOs, mappers, networking, DI, XCTest (Domain/Data layer changes)
  - docs/presentation-standards.md — MVVM, ViewState, SwiftUI views, design system
    (DSColors/DSSpacing/DSTypography), AppRouter, reusable components, XCUITest
    (Presentation layer changes)
  - docs/advanced-topics.md — optional topics: SPM modularization, local persistence
    (SwiftData/Core Data/Keychain), Swift 6 strict concurrency (apply only when needed)
  - docs/documentation-standards.md — documentation structure and maintenance rules
  - docs/openspec-tasks-mandatory-steps.md — mandatory task steps: feature branch,
    xcodebuild test, simulator verification, XCUITest, documentation update
  - docs/openspec-workflow.md — OPSX slash commands and Specboot workflow (/opsx:new, /opsx:ff,
    /opsx:apply, /opsx:verify, /opsx:archive)

  For implementation: adopt the relevant agent from ai-specs/agents/:
  - ai-specs/agents/domain-data-developer.md — for Domain and Data layer work
    (entities, use cases, repositories, DTOs, mappers, networking, DIContainer wiring)
  - ai-specs/agents/presentation-developer.md — for Presentation layer work
    (ViewModels, SwiftUI views, navigation routes, reusable components)
  Use ai-specs/skills/ for workflow guidance when applicable.

rules:
  _global:
    - Before creating any artifact, read and apply CLAUDE.md
    - Resolve concrete technical choices from docs/project-profile.md; if it is missing
      or all-TBD, run the adapt-standards skill before proceeding
    - For Domain/Data layer artifacts, read docs/domain-data-standards.md and adopt
      guidelines from ai-specs/agents/domain-data-developer.md
    - For Presentation layer artifacts, read docs/presentation-standards.md and adopt
      guidelines from ai-specs/agents/presentation-developer.md
    - All tasks.md files must follow docs/openspec-tasks-mandatory-steps.md

  tasks:
    - Step 0 must always be "Create feature branch"
    - Include xcodebuild test step (MANDATORY) with report in specs/<change>/reports/
    - Include simulator verification step for Presentation layer changes
    - Include XCUITest step when UI flows are affected
    - Last step must always be "Update Technical Documentation"
    - Break tasks into chunks of max 2–3 hours

  proposal:
    - Always include a "Non-goals" section
    - Reference the affected Clean Architecture layer(s) explicitly
    - Include test strategy (unit tests, simulator verification, XCUITest)
```

---

## Notes

- `docs/api-spec.yml` and `docs/data-model.md` do not exist yet in this project.
  Create them when you want to document the REST API endpoints consumed
  by the app and the domain entities (`<EntityA>Entity`, `<EntityB>Entity`, `<EntityC>Entity`).
  Once created, add them to the `context` block above.
- The `ai-specs/skills/` directory contains reusable workflow skills
  (`adapt-standards`, `enrich-us`, `commit`, `adversarial-review`, `code-auditing`, etc.)
  that the agent loads automatically when a request matches their description.
  Run `adapt-standards` once, before the first change, to populate `docs/project-profile.md`.
- OpenSpec slash commands use the `/opsx:` prefix. After `openspec init`, run
  `openspec config profile` (select expanded workflow) and `openspec update`. See
  `docs/openspec-workflow.md`.
