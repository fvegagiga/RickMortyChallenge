## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [x] 0.1 Create branch `feature/ci-pr-only-workflow` from `main`
- [x] 0.2 Verify current branch and working tree status before making changes

## 1. Update GitHub Actions Workflow

- [x] 1.1 Remove `push: branches: [main]` trigger; keep only `pull_request` in `.github/workflows/ios-tests.yml`
- [x] 1.2 Add `permissions: contents: read` at workflow level
- [x] 1.3 Add `concurrency` group keyed on `github.event.pull_request.number` with `cancel-in-progress: true`
- [x] 1.4 Add `actions/cache@v4` step for SPM cache path `~/Library/Caches/org.swift.swiftpm` keyed on `hashFiles('**/Package.resolved')`
- [x] 1.5 Add `actions/cache@v4` step for DerivedData path `~/Library/Developer/Xcode/DerivedData` keyed on `Package.resolved` and `project.pbxproj` hashes
- [x] 1.6 Add explicit `xcodebuild -resolvePackageDependencies` step before test execution
- [x] 1.7 Confirm existing test steps for `RickMortyChallenge` and `RickMortyChallengeScreenshotTests` schemes remain unchanged (same simulator destination)

## 2. Review and Update Existing Unit Tests (MANDATORY)

- [x] 2.1 Confirm no unit test changes are required for this CI-only workflow change (no app code modifications expected)

## 3. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [x] 3.1 Run full unit test suite: `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallenge -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" -only-testing:RickMortyChallengeTests`
- [x] 3.2 Create report `openspec/changes/ci-pr-only-workflow/specs/ci-ios-tests/reports/2026-06-09-step-3-unit-test-verification.md`
- [x] 3.3 Mark step complete only after all unit tests pass and the report exists

## 4. Run XCUITest Automated UI Tests (MANDATORY — AGENT MUST EXECUTE)

- [x] 4.1 Run XCUITests: `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallenge -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" -only-testing:RickMortyChallengeUITests`
- [x] 4.2 Create report `openspec/changes/ci-pr-only-workflow/specs/ci-ios-tests/reports/2026-06-09-step-4-xcuitest-verification.md`
- [x] 4.3 Mark step complete only after XCUITests pass and the report exists

## 5. Run Screenshot Tests (MANDATORY — AGENT MUST EXECUTE)

- [x] 5.1 Run screenshot tests: `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallengeScreenshotTests -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5"`
- [x] 5.2 Create report `openspec/changes/ci-pr-only-workflow/specs/ci-ios-tests/reports/2026-06-09-step-5-screenshot-test-verification.md`
- [x] 5.3 Mark step complete only after screenshot tests pass and the report exists

## 6. CI Workflow Verification (MANDATORY — AGENT MUST EXECUTE)

- [x] 6.1 Push branch and open a pull request; confirm **iOS Tests** workflow runs on the PR
- [x] 6.2 Verify cache restore/save steps appear in workflow logs
- [x] 6.3 Verify both test steps pass: `RickMortyChallenge` and `RickMortyChallengeScreenshotTests`
- [x] 6.4 After merge (or by inspecting Actions history), confirm no workflow run is triggered by push to `main`
- [x] 6.5 Create report `openspec/changes/ci-pr-only-workflow/specs/ci-ios-tests/reports/2026-06-09-step-6-ci-verification.md` with workflow run URL, cache status, and post-merge trigger confirmation

## 7. Update Technical Documentation (MANDATORY)

- [x] 7.1 Update `README.md` CI/CD section: state workflow runs on pull requests only (not on push to `main`)
- [x] 7.2 Mention caching and concurrency behaviour at a high level in the CI/CD section
- [x] 7.3 Confirm Testing Strategy section remains accurate (no test target changes)
