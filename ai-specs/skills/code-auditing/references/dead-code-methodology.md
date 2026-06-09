# Dead Code Detection Methodology

This document provides guidance on detecting and removing dead code in iOS Swift/SwiftUI projects using compiler warnings, grep analysis, and manual verification.

## Overview

Dead code is code that exists in the codebase but is never executed. It increases maintenance burden, binary size, and cognitive load. Swift's compiler and static analysis tools catch many cases automatically; this methodology covers the full spectrum including cases the compiler misses.

## Types of Dead Code

### 1. Unused Imports
`import` statements for modules never referenced in the file:
```swift
import Combine   // Never used in this file — remove it
import Foundation
```

### 2. Unused Functions/Methods
Functions defined but never called from outside test files:
```swift
private func legacyFormatDate(_ date: Date) -> String { ... }  // Never invoked
```

### 3. Unused Variables and Constants
`let`/`var` bindings declared but never read:
```swift
let result = try await fetchCharacters()   // result never used — just `try await`
```

### 4. Unused Types
`struct`, `class`, `enum`, or `protocol` declarations never referenced:
```swift
struct LegacyCharacterModel { ... }   // Replaced by CharacterEntity, never referenced
```

### 5. Unused Files
Entire Swift files not referenced (imported or instantiated) anywhere in the codebase.

### 6. Unused Swift Package Dependencies
Packages declared in `Package.swift` or the Xcode project that are never `import`ed in any source file.

### 7. Unreachable Code
Code after `return`, `throw`, `fatalError()`, or in `guard` branches:
```swift
func load() {
    return
    setupCache()  // Unreachable — Swift compiler warns on this
}
```

## Detection Approach for Swift

Unlike JavaScript/TypeScript ecosystems, Swift does not have a single "knip-style" dead code tool. Detection relies on three complementary approaches:

### Approach 1: Xcode Compiler Warnings (Fastest)

Build the project and review warnings — Swift's compiler flags:
- Unused `let` bindings (`let x = ...` where `x` is never read)
- Unused function result (`@discardableResult` not applied, result ignored)
- Unreachable code after `return`/`throw`
- Unused `import` statements (in newer Swift toolchains)

```bash
xcodebuild build \
  -scheme RickMortyChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep "warning:" | grep -i "unused\|never used\|unreachable"
```

### Approach 2: SwiftLint Rules (If Configured)

SwiftLint can flag:
- `unused_import` — import statements for unused modules
- `unused_declaration` — private declarations never referenced
- `unused_capture_list` — `[weak self]` when `self` is not captured

```bash
swiftlint lint --reporter json | jq '.[] | select(.rule_id | test("unused"))'
```

### Approach 3: Grep-Based Symbol Search

For `internal` and `public` symbols (not caught by compiler warnings on `private`):

```bash
# Find all function declarations in Domain/Data layers
grep -rn "func " RickMortyChallenge --include="*.swift" \
  | grep -v "override\|test\|Test\|init\|body\|Preview"

# For each symbol found, check if it is referenced anywhere
grep -rn "symbolName" . --include="*.swift" | wc -l
# If count == 1 (only the declaration), it may be dead code
```

```bash
# Find unused struct/class/enum types
grep -rn "^struct \|^final class \|^class \|^enum " \
  RickMortyChallenge --include="*.swift" \
  | awk -F': ' '{print $2}' | awk '{print $2}'
# Then grep each name to check reference count
```

## False Positive Detection

**CRITICAL: Always verify findings before reporting to the user.**

### Common False Positives in Swift

#### 1. Protocol Conformance Methods
```swift
// Looks unused but satisfies ObservableObject / URLSessionDataDelegate
func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, ...) { ... }
```

#### 2. `@objc` Methods
```swift
// Called by Objective-C runtime, selector, or NotificationCenter
@objc func handleAppDidBecomeActive() { ... }
```

#### 3. Entry Points and App Lifecycle
```swift
// App entry point — never "called" from Swift code directly
@main
struct RickMortyChallengeApp: App { ... }
```

#### 4. SwiftUI `body` and View Modifiers
```swift
// SwiftUI calls `body` implicitly
var body: some View { ... }
```

#### 5. `#Preview` Macros and Test Helpers
```swift
// Only used at preview/test time
#Preview { CharactersListView(...) }
final class MockCharacterRepository { ... }  // Only referenced in test files
```

#### 6. `@discardableResult` Functions
```swift
// Return value unused at call site but function is intentionally called for side effects
@discardableResult
func register(_ handler: Handler) -> Self { ... }
```

#### 7. Protocol Default Implementations
```swift
// Looks unused but provides default behaviour for protocol adopters
extension CharacterRepositoryProtocol {
    func fetchCharacterDetail(id: Int) async throws -> CharacterEntity { ... }
}
```

### Verification Checklist

For each flagged item, the agent MUST:

1. **Read the flagged code** to understand its context and layer
2. **Search for all references**:
   ```bash
   grep -rn "SymbolName" . --include="*.swift"
   ```
3. **Check protocol conformance**:
   - Is it satisfying a protocol method signature?
   - Is it a required initializer or lifecycle method?
4. **Check for `@objc` or selector usage**:
   - Is it decorated with `@objc`?
   - Is it referenced via `#selector(...)`?
5. **Check test and preview files**:
   - Is it only referenced in `*Tests.swift` or `#Preview` blocks? (valid — keep it)
6. **Check entry points**:
   - Is it `@main`, a scene delegate, or an `AppDelegate` method?

## Workflow

### 1. Run Detection

```bash
# Step 1: compiler warnings
xcodebuild build -scheme RickMortyChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep "warning:" | grep -i "unused\|unreachable" | sort -u

# Step 2: SwiftLint (if available)
swiftlint lint 2>/dev/null | grep -i "unused"

# Step 3: manual grep sweep for internal/public symbols (see above)
```

### 2. Categorize Findings

Group by type:
- Unused `import` statements
- Unused `private` declarations (compiler-flagged)
- Unused `internal`/`public` declarations (grep-identified)
- Unreachable code blocks
- Potentially unused files

### 3. Verify Each Finding

For each item:
1. Read the code
2. Apply the false positive checklist above
3. Mark as "verified dead" or "false positive — reason"

### 4. Present Verified Report

Show user:
- Summary counts (verified items only)
- Detailed list with file path and line number
- Items filtered out with reasons

### 5. Apply Fixes (After Approval)

Remove dead code only after user confirms. For each removal:
1. Delete the unused declaration or `import`
2. Rebuild: `xcodebuild build ...` — confirm zero new errors
3. Re-run tests: `xcodebuild test ...` — confirm no regressions

## Integration with Audits

### Quick Check Integration
- Run compiler warning grep as part of Phase 0 baseline
- Report findings under "Dead Code" category in the audit report
- Never auto-remove; present findings to the user first

### Deep Audit Integration
- Run as Phase 2.5: Dead Code Detection
- Include in the comprehensive report with file:line references
- Provide exact removal steps for the user to approve

## Best Practices

1. **Run regularly** — review compiler warnings after every significant refactor
2. **Configure SwiftLint** — add `unused_import` and `unused_declaration` to your `.swiftlint.yml`
3. **Test after removal** — always rebuild and re-run the full test suite after deleting dead code
4. **Review before commit** — manual verification recommended before removing `internal`/`public` symbols
5. **Document intentional exceptions** — comment why certain apparently-unused code is kept (e.g., `// Reserved for future protocol extension`)
6. **Start conservative** — better to miss some dead code than to break protocol conformance or test utilities
