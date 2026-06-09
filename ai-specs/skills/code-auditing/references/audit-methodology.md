# Code Audit Methodology

This document provides a comprehensive, systematic approach to code quality auditing for iOS Swift/SwiftUI projects. Follow these phases for thorough analysis.

## Phase 0: Pre-Analysis Setup

Before analyzing code, establish the context:

### 1. Project Configuration
- **Package files**: `Package.swift`, `.xcodeproj/project.pbxproj`
- **Tech stack**: Swift version, iOS deployment target, SwiftUI vs UIKit, local packages
- **Linting configs**: `.swiftlint.yml`, SwiftFormat config
- **Project docs**: `CLAUDE.md`, `README.md`, `docs/` for project-specific guidelines

### 2. Baseline Checks
Run existing linting and testing to establish a baseline before the audit:
```bash
# Build — check for compiler errors and warnings
xcodebuild build \
  -scheme RickMortyChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  | xcpretty

# Run all tests
xcodebuild test \
  -scheme RickMortyChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  | xcpretty

# SwiftLint (if configured)
swiftlint lint --reporter json
```

Document existing errors, warnings, and test failures as baseline.

### 3. Documentation Loading
Load official documentation for the frameworks in use:
- Apple Developer Docs for SwiftUI, Combine, XCTest, URLSession
- Swift Evolution proposals for language features in use
- Swift Package Index for any third-party dependencies

## Phase 1: Discovery

### File Identification
Find all Swift source files:
```bash
# All Swift files (excluding generated/build artifacts)
find . -name "*.swift" \
  -not -path "*/.git/*" \
  -not -path "*/DerivedData/*" \
  -not -path "*/.build/*"

# Group by Clean Architecture layer
find RickMortyChallenge/Domain -name "*.swift"
find RickMortyChallenge/Data -name "*.swift"
find RickMortyChallenge/Core -name "*.swift"
find RickMortyChallenge/Presentation -name "*.swift"
```

### Organization
- Group files by Clean Architecture layer (Domain → Data → Core → Presentation)
- Create a tracking list for systematic progress
- Prioritize Domain and Data layers (business-critical) over utilities

## Phase 2: File-by-File Analysis

For each file, analyze for the following categories:

### Dead Code
- Unused `import` statements (Xcode flags these as warnings)
- Unused `private` functions and methods (Xcode flags these)
- Unused variables and constants (Xcode flags `let` bindings)
- Unreachable code after `return` or `throw`
- Commented-out code blocks
- Deprecated Apple API usage still present

### Code Smells & Anti-Patterns
- Functions longer than 30 lines in Views or 50 lines in ViewModels
- High cyclomatic complexity (deeply nested `if`/`switch` chains)
- Magic numbers without named constants
- Copy-paste code duplication across features
- God ViewModels doing too much (mix of multiple concerns)
- Long parameter lists (> 4 params — use a struct instead)
- `// TODO:` and `// FIXME:` comments not tracked in tasks

### Security Vulnerabilities
- Hardcoded API keys, secrets, or credentials
- Sensitive data stored in `UserDefaults` (use Keychain instead)
- Sensitive data printed in `print()` or `Logger` calls
- Missing HTTPS (ATS disabled in `Info.plist`)
- URL construction from user input without proper encoding
- Information disclosure in user-facing error messages

### Performance Issues
- Synchronous/blocking operations on the main thread
- Heavy computation inside `body` computed properties (SwiftUI re-renders)
- Missing `LazyVStack`/`LazyVGrid` for unbounded lists
- Images loaded directly via `AsyncImage` instead of the cache layer
- Unnecessary `@Published` property updates triggering full re-renders
- Retain cycles in closures (`[weak self]` missing where needed)
- `Task` closures that strongly capture `self` in a `class`

### Swift Type Safety Issues
- Force unwrapping (`!`) outside test files
- Unsafe casts (`as!`) without fallback handling
- `Any` or `AnyObject` usage where generics or protocols are cleaner
- Missing `Sendable` conformance on types sent across actor boundaries
- Implicit `Optional` where the value is never actually nil

### Swift Concurrency Issues
- `DispatchQueue.main.async {}` instead of `@MainActor` or `MainActor.run {}`
- Completion handlers where `async throws` should be used
- Missing `await` on async calls
- `Task {}` created without storing the reference (cannot be cancelled)
- Missing `[weak self]` in long-lived `Task` closures
- Shared mutable state accessed from multiple tasks without actor isolation

### Memory Leaks
- Strong reference cycles (`class` A → `class` B → `class` A)
- `NotificationCenter` observers not removed on deinit
- `Timer` not invalidated on deinit
- Large data retained in closures beyond their needed lifetime

### Error Handling
- Empty `catch {}` blocks swallowing errors silently
- `try?` discarding errors that should surface to the user
- Generic error messages hiding the root cause
- `ViewState.failure` set but error not logged
- Errors propagated as `String` instead of typed `Error` enums

## Phase 3: Best Practices Verification

### Apple Documentation Check
For every major framework identified:

1. **Check current SwiftUI patterns** (e.g., `@Observable` macro in iOS 17+, `NavigationStack` vs old `NavigationView`):
   ```
   mcp__context7__resolve-library-id: "swiftui"
   mcp__context7__query-docs: { topic: "state management best practices" }
   ```

2. **Focus areas**:
   - Migration guides between iOS versions
   - Deprecated APIs and their replacements
   - Performance best practices (lazy loading, `.task`, `.onChange`)
   - Concurrency (Sendable, actor isolation, structured concurrency)
   - Common anti-patterns in SwiftUI (over-use of `@EnvironmentObject`, etc.)

### Cross-Reference Findings
- Compare actual implementation vs official documentation
- Identify use of deprecated APIs (e.g., `NavigationView` → `NavigationStack`)
- Note patterns that worked in older iOS versions but have better alternatives now
- Flag SwiftUI anti-patterns explicitly discouraged in Apple's documentation

## Phase 3.5: Clean Architecture Compliance

Verify that the dependency rule is respected across layers:

### Dependency Rule Checks
```bash
# Domain layer must NOT import Data, Core infrastructure, or UI frameworks
grep -rn "^import" RickMortyChallenge/Domain --include="*.swift" \
  | grep -v "Foundation\|XCTest"

# Data layer should only import Domain + networking
grep -rn "^import SwiftUI" RickMortyChallenge/Data --include="*.swift"

# Presentation layer must not directly call network services
grep -rn "NetworkService\|URLSession" RickMortyChallenge/Presentation --include="*.swift"
```

### Protocol vs Concrete Dependency
- Repository implementations injected via protocol, not concrete type
- Use cases injected via protocol in ViewModels
- `DIContainer` is the only place that wires concrete types

### ViewState Coverage
- Every screen ViewModel must use `ViewState<T>` — not boolean `isLoading` flags
- All `ViewState` cases must be handled exhaustively in the View switch

## Phase 4: Pattern Detection

Look for recurring issues across the codebase:

### Cross-File Patterns
- Same anti-pattern repeated in multiple ViewModels or Views
- Duplicated mapper logic across entity mappers
- Inconsistent error handling (some use `ViewState.failure`, others use separate `@Published var errorMessage`)
- Different async patterns in the same layer (mix of callbacks and async/await)

### Abstraction Opportunities
- Repeated pagination logic that could be a generic `PaginatedViewModel`
- Common loading/error/empty state handling extracted to `ViewState`
- Repeated `LazyVGrid` column configuration that could be a constant

### Inconsistencies
- Mixed naming: some VMs use `loadInitial()`, others `fetchData()` for the same concept
- Inconsistent `@MainActor` annotation (some VMs annotated, some not)
- Different error propagation strategies in repositories

## Phase 5: Swift Package Recommendations

For custom implementations, find mature Swift replacements:

### Discovery Process
1. **Check Apple frameworks first** — many common needs are covered by Foundation, Combine, or Swift standard library
2. **Search Swift Package Index** (swiftpackageindex.com) for community packages
3. **Verify package health**:
   - Recent releases compatible with the project's Swift version
   - Active maintenance (commits in the last 6 months)
   - Compatible minimum iOS deployment target
   - No unaddressed security advisories

### Evaluation Criteria
- **Maintenance**: Last release < 6 months
- **Adoption**: Stars, forks, Swift Package Index compatibility badges
- **Security**: No unaddressed vulnerabilities
- **Binary size impact**: Relevant for app size budget
- **API stability**: Semantic versioning, migration guides
- **Documentation**: Clear examples and API docs

### Common Swift Replacements
| Custom Implementation | Recommended Approach |
|---|---|
| Manual retry logic | `RetryingNetworkService` wrapper (already in project) |
| Image caching | `ImageCacheManager` (already in project) |
| Date formatting | `DateFormatter` with cached instances |
| Deep equality | `Equatable` conformance on entities |
| JSON decoding | `Codable` + `JSONDecoder` (already used) |
| Dependency injection | `DIContainer` (already in project) |

## Phase 6: Report Generation

### Report Structure

#### Executive Summary (2–3 paragraphs)
- Total Swift files analyzed, grouped by layer
- High-level findings overview
- Key risks and recommendations

#### Critical Issues (Immediate Action)
For each:
- File path and line number
- Issue description
- Security/stability impact
- Swift fix example
- Effort estimate

#### High Priority Issues
- Performance bottlenecks
- Architecture violations (dependency rule broken)
- Missing error handling

#### Medium Priority Issues
- Best practices violations
- Code quality concerns
- Type safety improvements

#### Low Priority Issues
- Style inconsistencies
- Minor improvements
- Documentation gaps

#### Swift Package Recommendations
For each suggested package or refactor:
- Current custom code location
- Recommended approach
- Migration effort

#### Quick Wins
Low-effort, high-value fixes:
- < 30 minutes to implement
- High impact on quality/security

#### Action Plan
Prioritized steps with:
- Effort estimates (S/M/L/XL)
- Dependencies between tasks
- Suggested sprint allocation

### Report Format Requirements

Each issue should include:
```markdown
### [PRIORITY] Issue Title
**Location:** `RickMortyChallenge/Data/Repositories/CharacterRepositoryImpl.swift:42`

**Problem:**
Description of the issue and why it matters.

**Before:**
```swift
// problematic Swift code
```

**After:**
```swift
// fixed Swift code
```

**Effort:** S (< 30 min) | M (1–4 hours) | L (4–8 hours) | XL (> 8 hours)
```

## Common Pitfalls to Avoid

1. **Don't rely on assumptions** — always verify with Apple documentation
2. **Don't suggest outdated patterns** — check current Swift/SwiftUI best practices
3. **Don't recommend unmaintained packages** — verify Swift Package Index activity
4. **Don't ignore project conventions** — respect `CLAUDE.md` guidelines and `docs/`
5. **Don't break functionality** — ensure fixes are safe
6. **Don't over-engineer** — consider cost/benefit ratio
7. **Don't skip Swift type safety** — types and protocols are documentation
8. **Don't ignore the Clean Architecture dependency rule** — it is the project's core invariant

## Performance Optimization

For large codebases:
- **Parallel processing**: analyze multiple files simultaneously
- **Batch operations**: group similar checks (all `@MainActor` checks together, etc.)
- **Selective scanning**: focus on changed files first
- **Cache documentation**: reuse framework doc lookups
- **Progressive reporting**: provide interim results per layer
