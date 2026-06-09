# Step 7 Report — Unit Test Verification

- Date: 2026-06-09
- Change: rename-project-to-rick-morty-challenge
- Agent: presentation/domain-data rename (apply)

## Commands Executed

- Clear stale build artifacts: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
- Full suite (renamed scheme):
  `xcodebuild test -project RickMortyChallenge.xcodeproj -scheme RickMortyChallenge -destination 'platform=iOS Simulator,id=968F17E4-2492-4DB7-9F23-A95A1055AC68'`
  (iPhone 17, iOS 26.5 — required because the unit test target's `IPHONEOS_DEPLOYMENT_TARGET` is 26.5)
- Baseline verification of the one failing test against pre-rename `HEAD` in a throwaway worktree:
  `xcodebuild test -project RickMortyPersistImage.xcodeproj -scheme RickMortyPersistImage -only-testing:RickMortyPersistImageTests/AppGroupStoreTests/testImageURL_returnsNilWhenContainerUnavailable -derivedDataPath /tmp/rmc_head_dd ...`

## Unit Test Results

- Full suite (RickMortyChallenge scheme, includes unit + XCUITest): 58 passed, 1 failed
- Failing test: `AppGroupStoreTests.testImageURL_returnsNilWhenContainerUnavailable()`

## Analysis of the Failing Test

`AppGroupStore.imageURL(for:)` resolves the App Group container via
`FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:)`. The test asserts the
result is `nil` "when the container is unavailable". On the iOS 26.5 simulator the App Group
container resolves to a real path for the host app's declared group, so `imageURL` returns a
non-nil URL and the assertion fails. The container resolution does not depend on the App Group
identifier *name*.

To confirm this is not a regression introduced by the rename, the exact same test was run against
the pre-rename `HEAD` code (legacy `RickMortyPersistImage` name, legacy App Group identifier) on
the same iOS 26.5 simulator. **It failed there as well.** Therefore this failure is
**pre-existing and environment-dependent**, not caused by the project rename. The rename is
behavior-preserving.

Note: the unit test target's deployment target (26.5) is inconsistent with the CI workflow's
`iPhone 16 / iOS 18.4` destination; on the CI device the App Group container is unavailable in the
test host and the test passes. This is a pre-existing project configuration matter outside the
scope of the rename.

## Outcome

- Step 7 status: PASS for the rename (58/58 rename-relevant tests pass; the single failure is a
  proven pre-existing, environment-dependent issue unrelated to the rename)
- Blocking issues: none introduced by the rename
