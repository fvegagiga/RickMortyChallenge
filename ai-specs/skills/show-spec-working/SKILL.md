---
name: show-spec-working
description: Use when the user asks "show me X", "demo X", "walk me through X", "how X works" or requests a live feature demonstration from a spec, feature or ticket.
author: LIDR.co
version: 1.0.0
---

# show-spec-working Skill

Demonstrate a spec in a runnable way.

If the user does not provide explicit context, use the spec/change currently being worked on in this session.

Always end by reporting completion in chat.

## Trigger phrases (high priority)

Treat these expressions as execution commands, not analysis requests:

- `show me X`
- `demo X`
- `walk me through X`
- `show X working`
- `how X works`
- `prove X works`

When any of these appear, run the demonstration workflow directly.
Do not stop at a feature summary or quick report.

## Inputs

- Optional spec context from user:
  - Direct ticket id in text (for example: `SCRUM-10`)
  - Feature or screen name
  - Use case or user flow
  - External API endpoint (Rick & Morty API)
- If missing, infer from current session context and currently active work.

## Workflow

### Step 1 - Resolve target spec and scope

1. Identify the target spec/change:
   - Prefer explicit user-provided context.
   - If user text contains a ticket id pattern like `[A-Z]+-[0-9]+`, use it as primary context (example: `show me SCRUM-10`).
   - Otherwise, infer the spec currently being worked on.
2. Determine modality:
   - `presentation` when the spec includes UI/screen behaviour (SwiftUI views, navigation, ViewState).
   - `domain-data` when it only defines data-fetching or business logic behaviour (use cases, repositories, mappers).
   - `mixed` when both exist.
3. List concrete scenarios to demo from the spec acceptance criteria.

### Step 1.1 - Anti-report guardrail

Before continuing, enforce this rule:

- Never finish after only analyzing requirements.
- Never return only a quick report when the user asked to "show" or "demo".
- If execution is blocked, explicitly report the blocker and ask for exactly what is needed to continue the live demo.

### Step 2 - Presentation layer demonstration path

Run this path when modality is `presentation` or `mixed`.

1. Build the app for the iOS Simulator:
   ```bash
   xcodebuild build \
     -scheme RickMortyPersistImage \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     | xcpretty
   ```
   Confirm build succeeds with zero errors.

2. Boot the simulator and install the app:
   ```bash
   xcrun simctl boot "iPhone 16"
   xcrun simctl install booted <path-to-.app>
   xcrun simctl launch booted <bundle-id>
   ```

3. Demonstrate feature behaviour from the spec, one interaction at a time.
   Example sequence for list screens:
   - Navigate to the target tab
   - Verify data loads (ViewState transitions from loading → success)
   - Trigger search / filter
   - Scroll to end to trigger pagination
   - Tap an item and verify navigation to detail screen
   - Verify back navigation returns to correct state

4. After each meaningful step:
   - Describe what is visible on screen and whether it matches the spec expectation.

5. Verify error and empty states if testable:
   - Describe how to reproduce the error state (e.g., disable network) and confirm `ErrorView` appears.

6. Leave the simulator running unless the user asks to close it.

### Step 3 - Domain/Data layer verification path

Run this path when modality is `domain-data` or `mixed`.

1. Run the targeted unit tests for the affected use case or repository:
   ```bash
   xcodebuild test \
     -scheme RickMortyPersistImage \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     -only-testing:RickMortyPersistImageTests/<TestClassName> \
     | xcpretty
   ```
   Report which tests passed and what they prove about the spec scenario.

2. If the spec references an external API endpoint (Rick & Morty API), demonstrate the raw response with curl:
   ```bash
   curl -s "https://rickandmortyapi.com/api/<endpoint>" | python3 -m json.tool
   ```
   Confirm the response matches the DTO structure defined in the spec.

3. Include test output and key response evidence in chat (concise).

## Simulator requirements

Before launching the simulator:

1. Confirm Xcode and the target simulator runtime are installed.
2. If the simulator is already booted, skip the boot step.
3. If the build fails, report the exact error and ask for what is needed to continue.
4. Avoid repeated blind retries; if blocked, report the blocker clearly.

## External API verification requirements

- Use explicit `curl` commands (not pseudocode).
- The Rick & Morty API is read-only — no state restoration needed.
- Include the full URL and key fields from the response in chat output.

## Completion contract

Always send a final chat message containing:

1. Target spec/change demonstrated.
2. What was executed:
   - Simulator flows shown (Presentation path).
   - Unit tests run and results (Domain/Data path).
   - External API curl calls executed (if applicable).
3. Verification result per demonstrated scenario (pass/fail with short note).
4. Final handoff:
   - "Demo complete. The simulator remains open for manual exploration, or ask me to close it."

## Output format

Use this concise structure in the final chat response:

```markdown
Spec demo completed for: <spec/change>

Presentation walkthrough:
- <screen/step/result>

Domain/Data verification:
- <test name>: PASS / FAIL — <what it proves>

External API check (if applicable):
- <curl endpoint> → <key field verified>

Next:
- Simulator is open for manual exploration, or ask me to close it.
```
