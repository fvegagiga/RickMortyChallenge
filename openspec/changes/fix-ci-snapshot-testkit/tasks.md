## 0. Setup: Create Feature Branch (MANDATORY — FIRST STEP)

- [ ] 0.1 Create branch `cursor/fix-ci-snapshot-testkit` from `main`
- [ ] 0.2 Verify current branch and working tree status before making changes

## 1. Version SnapshotTestKit Local Package

- [ ] 1.1 Update `.gitignore` to allow `Packages/SnapshotTestKit/` while ignoring `Packages/**/.build/` and `Packages/**/.swiftpm/`
- [ ] 1.2 Add `Packages/SnapshotTestKit/Package.swift` and `Packages/SnapshotTestKit/Sources/SnapshotTestKit/SnapshotTestKit.swift` to git
- [ ] 1.3 Confirm `git check-ignore` no longer excludes the SnapshotTestKit source files

## 2. Align Deployment Targets for CI

- [ ] 2.1 Set project-level `IPHONEOS_DEPLOYMENT_TARGET` to `16.6` in `RickMortyChallenge.xcodeproj/project.pbxproj`
- [ ] 2.2 Set `RickMortyChallengeTests` deployment target to `16.6`
- [ ] 2.3 Set `CharacterWidgetExtensionExtension` deployment target to `17.0` explicitly
- [ ] 2.4 Verify the app target remains at iOS `16.6` and screenshot tests remain at iOS `16.6`

## 3. Local Build Verification

- [ ] 3.1 Run `xcodebuild build-for-testing` for `RickMortyChallenge` scheme with destination `platform=iOS Simulator,name=iPhone 16,OS=18.4`
- [ ] 3.2 Run `xcodebuild build-for-testing` for `RickMortyChallengeScreenshotTests` scheme with the same CI destination
- [ ] 3.3 Confirm `SnapshotTestKit` resolves from `Packages/SnapshotTestKit @ local` in build output

## 4. Review and Update Existing Unit Tests (MANDATORY)

- [ ] 4.1 Review unit tests for regressions caused by deployment-target changes (no new tests expected)
- [ ] 4.2 Confirm existing screenshot tests still compile against the versioned `SnapshotTestKit` package

## 5. Run Unit Tests with xcodebuild (MANDATORY — AGENT MUST EXECUTE)

- [ ] 5.1 Run targeted unit tests: `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallenge -destination "platform=iOS Simulator,name=iPhone 16,OS=18.4" -only-testing:RickMortyChallengeTests`
- [ ] 5.2 Run full unit test suite for `RickMortyChallengeTests`
- [ ] 5.3 Create report `openspec/changes/fix-ci-snapshot-testkit/specs/ci-ios-tests/reports/2026-06-09-step-5-unit-test-verification.md`
- [ ] 5.4 Mark step complete only after all unit tests pass and the report exists

## 6. Run XCUITest Automated UI Tests (MANDATORY — AGENT MUST EXECUTE)

- [ ] 6.1 Run XCUITests: `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallenge -destination "platform=iOS Simulator,name=iPhone 16,OS=18.4" -only-testing:RickMortyChallengeUITests`
- [ ] 6.2 Create report `openspec/changes/fix-ci-snapshot-testkit/specs/ci-ios-tests/reports/2026-06-09-step-6-xcuitest-verification.md`
- [ ] 6.3 Mark step complete only after XCUITests pass and the report exists

## 7. Run Screenshot Tests (MANDATORY — AGENT MUST EXECUTE)

- [ ] 7.1 Run screenshot tests: `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallengeScreenshotTests -destination "platform=iOS Simulator,name=iPhone 16,OS=18.4"`
- [ ] 7.2 Create report `openspec/changes/fix-ci-snapshot-testkit/specs/ci-ios-tests/reports/2026-06-09-step-7-screenshot-test-verification.md`
- [ ] 7.3 Mark step complete only after screenshot tests pass and the report exists

## 8. CI Workflow Verification (MANDATORY — AGENT MUST EXECUTE)

- [ ] 8.1 Push branch to remote and confirm GitHub Actions **iOS Tests** workflow runs for the branch
- [ ] 8.2 Verify both workflow steps pass: `RickMortyChallenge` and `RickMortyChallengeScreenshotTests`
- [ ] 8.3 Create report `openspec/changes/fix-ci-snapshot-testkit/specs/ci-ios-tests/reports/2026-06-09-step-8-ci-verification.md` with workflow run URL and outcome

## 9. Update Technical Documentation (MANDATORY)

- [ ] 9.1 Update `README.md` Testing Strategy section to mention the versioned local `SnapshotTestKit` package under `Packages/`
- [ ] 9.2 Document the `.gitignore` exception pattern for future local packages if applicable
- [ ] 9.3 Confirm CI section still accurately describes the iPhone 16 / iOS 18.4 simulator profile
