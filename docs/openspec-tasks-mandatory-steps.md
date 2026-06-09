---
description: Enforce mandatory steps when creating tasks.md artifacts for iOS Swift/SwiftUI projects — including unit tests, simulator verification, XCUITest, and documentation updates.
alwaysApply: true
---

# OpenSpec Tasks: Mandatory Steps Enforcement

When creating or updating `tasks.md` artifacts in OpenSpec changes, you MUST:

## 1. Read openspec/config.yaml First

**BEFORE** creating or updating any `tasks.md` file, you MUST read `openspec/config.yaml` to understand:
- Project-specific mandatory steps and overrides
- Branch naming conventions
- Task structure requirements
- Testing and documentation requirements

## 2. Mandatory Steps

All implementation tasks MUST include these steps in the correct order:

### Step 0: Create Feature Branch (MUST BE FIRST)
- **Location**: Must be the very first step (Step 0)
- **Branch naming**: `feature/[ticket-id]` or `feature/[change-name]`
- **Action**: Create and switch to the feature branch before any code changes

### Mandatory Steps (Must Be Included):

- **Step N**: Review and Update Existing Unit Tests (MANDATORY)
- **Step N+1**: Run Unit Tests with xcodebuild (MANDATORY) — **AGENT MUST EXECUTE**
- **Step N+2**: Manual Simulator Verification (MANDATORY) — **AGENT MUST EXECUTE** if app can be built and run
- **Step N+3**: XCUITest Automated UI Tests (MANDATORY if applicable) — **AGENT MUST EXECUTE**
- **Step N+4**: Update Technical Documentation (MANDATORY)

## 3. Manual Testing Requirements — CRITICAL: Agent Must Execute

**IMPORTANT**: The coding agent (AI) MUST perform all testing steps itself. **NEVER delegate testing to the user**. These tests must be executed by the agent to mark tasks as completed in `tasks.md`.

---

### Step N+1: Run Unit Tests with xcodebuild (MANDATORY)

**Agent Responsibility**: The coding agent MUST execute unit tests using `xcodebuild test`, verify results, and produce a test report artifact. This is NOT optional and cannot be delegated to the user.

**Implementation Steps** (Agent must perform):

1. **Prepare Test Environment**:
   - Verify all Swift Package dependencies are resolved
   - Confirm the test target and scheme to use
   - Document the exact `xcodebuild test` command that will be executed

2. **Run Targeted Tests First**:
   - Execute focused tests for the modified module(s):
     ```bash
     xcodebuild test \
       -scheme RickMortyChallenge \
       -destination 'platform=iOS Simulator,name=iPhone 16' \
       -only-testing:RickMortyChallengeTests/[TestClassName] \
       | xcpretty
     ```
   - Confirm failures are resolved and no new regressions appear in targeted scope

3. **Run Full Unit Test Suite**:
   - Execute the complete test suite:
     ```bash
     xcodebuild test \
       -scheme RickMortyChallenge \
       -destination 'platform=iOS Simulator,name=iPhone 16' \
       | xcpretty
     ```
   - Record total test counts, failures, runtime, and any flaky behaviour observed

4. **Create Unit Test Verification Report in Spec Folder**:
   - Save report under `specs/<change-name>/reports/`
   - Filename pattern: `YYYY-MM-DD-step-N+1-unit-test-verification.md`
   - Include executed commands, summarised results, and any failures

5. **Mark Task as Completed**: Only after all unit tests pass (or approved exceptions are documented) and the report is created, mark Step N+1 as completed in `tasks.md`.

**Report Template** (store in `specs/<change-name>/reports/`):
```markdown
# Step N+1 Report — Unit Test Verification

- Date: YYYY-MM-DD
- Change: <change-name>
- Agent: <agent-name>

## Commands Executed
- `<command 1>`
- `<command 2>`

## Unit Test Results
- Targeted tests: X passed, Y failed, Z skipped
- Full suite: X passed, Y failed, Z skipped
- Runtime: <duration>
- Notes: <flaky tests, retries, exceptions>

## Outcome
- Step N+1 status: PASS / FAIL
- Blocking issues: <none or list>
```

**Dependencies**:
- Xcode and iOS Simulator installed
- Swift Package dependencies resolved (`swift package resolve` if needed)
- Permission to create report files in `specs/<change-name>/reports/`

**Notes**:
- **The agent MUST execute tests itself** — never ask the user to run tests
- This step is mandatory even when code changes appear small
- Report naming must follow the required pattern for traceability
- **Task completion in tasks.md can only be marked after report creation**

---

### Step N+2: Manual Simulator Verification (MANDATORY)

**Agent Responsibility**: The coding agent MUST build and run the app on the iOS Simulator, navigate to the affected feature, and verify the expected behaviour visually. This is NOT optional and cannot be delegated to the user.

**When This Applies**:
- Any change that affects the Presentation layer (ViewModels, Views, Components)
- Any change that affects data displayed to the user (new fields, formatting, pagination)
- Navigation changes (new routes, tab changes)

**Implementation Steps** (Agent must perform):

1. **Build the App**:
   ```bash
   xcodebuild build \
     -scheme RickMortyChallenge \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     | xcpretty
   ```
   - Confirm the build succeeds with zero errors and zero warnings
   - Resolve any compiler warnings introduced by the change

2. **Launch and Navigate**:
   - Boot the simulator if not already running:
     ```bash
     xcrun simctl boot "iPhone 16"
     ```
   - Install and launch the app:
     ```bash
     xcrun simctl install booted <path-to-.app>
     xcrun simctl launch booted <bundle-identifier>
     ```
   - Navigate to the screen or feature affected by the change

3. **Verify Happy Path**:
   - Confirm data loads correctly (correct fields, formatting, images)
   - Confirm pagination triggers when scrolling to the end of a list
   - Confirm search/filter updates results correctly

4. **Verify Error and Empty States**:
   - If testable, simulate network failure and verify `ErrorView` appears with retry
   - Verify empty state displays correctly when no results are returned

5. **Verify Navigation**:
   - Confirm navigation to detail screens works
   - Confirm back navigation returns to the correct state

6. **Document Findings**:
   - Save a brief verification report in `specs/<change-name>/reports/`
   - Filename pattern: `YYYY-MM-DD-step-N+2-simulator-verification.md`
   - List each scenario checked and its outcome (PASS / FAIL)

7. **Mark Task as Completed**: Only after all scenarios pass, mark Step N+2 as completed in `tasks.md`.

**Dependencies**:
- Xcode and iOS Simulator installed and configured
- App builds successfully (Step N+1 must pass first)

**Notes**:
- **The agent MUST perform the verification itself** — never ask the user to check the simulator
- If the agent cannot launch the simulator (e.g., headless environment), document this explicitly and describe what was verified via unit tests instead
- **Task completion in tasks.md can only be marked after successful verification**

---

### Step N+3: XCUITest Automated UI Tests (MANDATORY if applicable)

**Agent Responsibility**: The coding agent MUST execute XCUITest UI tests for affected user flows. This is NOT optional and cannot be delegated to the user.

**When This Applies**:
- New screens or navigation flows added to the Presentation layer
- Changes to existing user-facing interactions (buttons, forms, gestures)
- Any change that affects the critical path (characters list → character detail, tab navigation)

**Implementation Steps** (Agent must perform):

1. **Prepare Test Environment**:
   - Ensure the iOS Simulator is booted and the app can be installed
   - Identify which XCUITest test classes cover the affected feature
   - Check `accessibilityIdentifier` values are set on key UI elements — add them if missing

2. **Run Targeted XCUITests**:
   ```bash
   xcodebuild test \
     -scheme RickMortyChallenge \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     -only-testing:RickMortyChallengeUITests/[TestClassName] \
     | xcpretty
   ```

3. **Run Full UI Test Suite**:
   ```bash
   xcodebuild test \
     -scheme RickMortyChallenge \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     -testPlan RickMortyChallengeTests \
     | xcpretty
   ```

4. **Test User Workflows**:
   - Characters list loads and displays items
   - Tapping a character navigates to the detail screen
   - Tab navigation between Characters, Episodes, Locations
   - Pull-to-refresh triggers a reload
   - Search filters the list correctly

5. **Test Error Scenarios**:
   - Verify error state displays the retry button
   - Verify empty state displays the correct message

6. **Create XCUITest Report**:
   - Save report in `specs/<change-name>/reports/`
   - Filename pattern: `YYYY-MM-DD-step-N+3-xcuitest-verification.md`
   - Include test commands, scenario list, and outcomes

7. **Mark Task as Completed**: Only after all XCUITests pass and the report is created, mark Step N+3 as completed in `tasks.md`.

**Notes**:
- **The agent MUST execute all XCUITests itself** — never ask the user to run them
- Use `waitForExistence(timeout:)` — never hardcode `sleep` waits
- Add `accessibilityIdentifier` to key elements if they are missing and XCUITest needs them
- Document all test scenarios and outcomes for future reference
- **Task completion in tasks.md can only be marked after successful execution of all UI tests**

---

## 4. Verification Checklist

Before finalising any `tasks.md` file, verify:
- [ ] Step 0 (Create Feature Branch) is the FIRST step
- [ ] All mandatory steps from `openspec/config.yaml` are included
- [ ] Steps are numbered sequentially
- [ ] Mandatory steps are clearly marked with "(MANDATORY)" label
- [ ] Branch naming follows the convention: `feature/[name]`
- [ ] Step N+1 includes the `xcodebuild test` command and report path
- [ ] Step N+2 (Simulator Verification) is included for Presentation layer changes
- [ ] Step N+3 (XCUITest) is included if UI flows are affected
- [ ] Manual testing steps explicitly state "AGENT MUST EXECUTE"
- [ ] Step N+4 (Update Technical Documentation) is the last step

## 5. When This Applies

This rule applies when:
- Creating `tasks.md` via `/opsx:ff` (fast-forward) or `openspec-ff-change` skill
- Creating `tasks.md` via `/opsx:continue` (continue change) or `openspec-continue-change` skill
- Updating existing `tasks.md` files
- Implementing tasks from `tasks.md` via `/opsx:apply` or `openspec-apply-change` skill — the agent must execute manual tests

## 6. Example Structure

```markdown
## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [ ] 0.1 Create feature branch `feature/episode-detail` from main branch
- [ ] 0.2 Verify branch creation and current branch status

## 1. Domain: EpisodeDetailEntity and Use Case (TDD)

- [ ] 1.1 Write failing test for GetEpisodeDetailUseCase
- [ ] 1.2 Add entity fields and use case protocol
- [ ] 1.3 Implement use case to make tests pass

## 2. Data: DTO, Mapper, Repository

- [ ] 2.1 Add EpisodeDetailDTO
- [ ] 2.2 Update EpisodeMapper
- [ ] 2.3 Add fetchEpisodeDetail to EpisodeRepositoryImpl
- [ ] 2.4 Add APIEndpoint.episodeDetail case

## 3. Presentation: ViewModel and Views

- [ ] 3.1 Implement EpisodeDetailViewModel with ViewState
- [ ] 3.2 Create EpisodeDetailView with exhaustive ViewState switch
- [ ] 3.3 Add EpisodeRoute.detail case to AppRouter
- [ ] 3.4 Register navigationDestination in EpisodesListView
- [ ] 3.5 Add #Preview macros for all states

## 4. Core: Wire into DIContainer

- [ ] 4.1 Add makeEpisodeDetailViewModel factory to DIContainer

## 5. Review and Update Existing Unit Tests (MANDATORY)

- [ ] 5.1 Review existing tests for regressions
- [ ] 5.2 Update MockDataFactory if new fields are needed
- [ ] 5.3 Update MockEpisodeRepository with new method

## 6. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [ ] 6.1 Run targeted tests for changed modules
- [ ] 6.2 Run full unit test suite
- [ ] 6.3 Create report `specs/<change-name>/reports/YYYY-MM-DD-step-6-unit-test-verification.md`
- [ ] 6.4 Mark step complete only after all tests pass and report exists

## 7. Manual Simulator Verification (MANDATORY — AGENT MUST EXECUTE)

- [ ] 7.1 Build app for simulator — verify zero errors
- [ ] 7.2 Navigate to Episodes tab and tap an episode
- [ ] 7.3 Verify EpisodeDetailView renders all fields correctly
- [ ] 7.4 Verify back navigation returns to Episodes list
- [ ] 7.5 Create report `specs/<change-name>/reports/YYYY-MM-DD-step-7-simulator-verification.md`

## 8. XCUITest Automated UI Tests (MANDATORY — AGENT MUST EXECUTE)

- [ ] 8.1 Run targeted XCUITests for Episodes flow
- [ ] 8.2 Verify episode detail navigation test passes
- [ ] 8.3 Create report `specs/<change-name>/reports/YYYY-MM-DD-step-8-xcuitest-verification.md`

## 9. Update Technical Documentation (MANDATORY)

- [ ] 9.1 Update docs/domain-data-standards.md if new patterns are introduced
- [ ] 9.2 Update docs/presentation-standards.md if new UI patterns are introduced
- [ ] 9.3 Update openspec/config.yaml context if the project stack changes
```

## 7. Agent Execution Requirements

**CRITICAL**: When implementing tasks from `tasks.md` (via `openspec-apply-change` skill or `/opsx:apply`), the coding agent MUST:

1. **Execute All Tests**: Never ask the user to run `xcodebuild test` or verify the simulator. The agent must:
   - Run `xcodebuild test` and capture the output
   - Build and verify the app on the simulator for Presentation layer changes
   - Run XCUITests for UI flow changes
   - Verify all results and outcomes

2. **Mark Tasks as Completed**: Tasks can ONLY be marked as completed (`[x]`) in `tasks.md` AFTER:
   - The agent has successfully executed all required tests
   - All test results have been verified
   - All test outcomes have been documented in reports

3. **Never Delegate Testing**: The agent must never:
   - Ask the user to run `xcodebuild test`
   - Ask the user to check the simulator manually
   - Ask the user to run XCUITests
   - Mark tasks as completed without executing tests
   - Skip mandatory testing steps

4. **Document Test Execution**: The agent must document:
   - All `xcodebuild` commands executed
   - All test results (passed, failed, skipped counts)
   - All simulator verification scenarios checked
   - All XCUITest scenarios executed
   - Any issues encountered and their resolutions

## Failure to Follow

If you create tasks without following these mandatory steps, the user will need to manually fix the `tasks.md` file. Always read `openspec/config.yaml` first and ensure all mandatory steps are included.

**If you implement tasks without executing the tests yourself, you are violating this rule. The agent must execute all tests to mark tasks as completed.**
