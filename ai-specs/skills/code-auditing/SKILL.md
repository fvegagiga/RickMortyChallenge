---
name: code-auditing
description: Task-focused project skill.
version: 1.0.0
---
# Code Auditing Skill

Comprehensive methodology for systematic code quality audits of iOS Swift/SwiftUI projects.

## When to Use

- Comprehensive code quality audits
- Security vulnerability assessments
- Technical debt identification
- Pre-release code reviews
- Best practices verification
- Swift Package dependency audits

## Audit Phases

### Phase 0: Pre-Analysis Setup
1. Check for project configuration files (`Package.swift`, `.xcodeproj`, `.swiftlint.yml`)
2. Identify tech stack and Swift Package dependencies
3. Check for linting/formatting configs (SwiftLint rules)
4. Run existing linting and test commands as baseline:
   ```bash
   swiftlint lint                                    # if SwiftLint is installed
   xcodebuild build -scheme RickMortyPersistImage \
     -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty
   xcodebuild test -scheme RickMortyPersistImage \
     -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty
   ```
5. Load documentation for identified core frameworks (Swift, SwiftUI, Combine, XCTest)

### Phase 1: Discovery
1. Find all Swift source files: `find . -name "*.swift" -not -path "*/.git/*"`
2. Create a tracking list for each file
3. Group files by Clean Architecture layer (Domain, Data, Core, Presentation) for contextual analysis

### Phase 2: File-by-File Analysis
For each file, analyze for:
- Dead code (unused functions, variables, `import` statements)
- Code smells and anti-patterns
- Custom implementations that could use Swift standard library or existing SPM packages
- Security vulnerabilities
- Performance issues
- Outdated patterns or deprecated Swift/SwiftUI APIs
- Missing error handling
- Overly complex functions
- Duplicate code across layers

### Phase 3: Best Practices Verification
For every framework and library in use:
1. Retrieve official documentation (Apple Developer Docs, Swift Evolution)
2. Compare implementation against official patterns
3. Identify deviations from recommendations
4. Note outdated patterns (e.g., `@ObservedObject` where `@StateObject` is correct, completion handlers instead of `async/await`)
5. Flag discouraged anti-patterns

### Phase 4: Pattern Detection
Look for recurring issues:
- Common anti-patterns across files (e.g., force unwrapping, `DispatchQueue.main.async` instead of `@MainActor`)
- Duplicated logic that could be abstracted
- Inconsistent naming conventions (camelCase vs PascalCase misuse)
- Missing error handling patterns

### Phase 5: Swift Package Recommendations
For custom implementations:
1. Check if Swift standard library or Apple frameworks already provide the functionality
2. Search Swift Package Index (swiftpackageindex.com) for mature packages
3. Verify package health (recent releases, active maintenance, Swift version compatibility)
4. Check compatibility with the project's minimum iOS deployment target

### Phase 6: Comprehensive Report
Generate detailed report with:
- Executive summary
- Critical issues requiring immediate attention
- File-by-file findings
- Prioritized action plan
- Effort estimates
- Swift Package recommendations

## Issue Priority Levels

- **Critical** - Security vulnerabilities, broken functionality, data loss risk
- **High Priority** - Performance bottlenecks, architecture violations, unmaintainable code
- **Medium Priority** - Code quality, best practices deviations, missing tests
- **Low Priority** - Style, minor improvements
- **Quick Wins** - Less than 30 minutes to fix

## Analysis Categories

### Security
- Hardcoded secrets or API keys
- Sensitive data stored insecurely (UserDefaults instead of Keychain)
- Missing HTTPS enforcement
- Exposed sensitive data in logs or error messages
- Missing input sanitization in URL construction

### Performance
- Inefficient algorithms in hot paths
- Main thread blocking operations (synchronous network calls, heavy computation on `@MainActor`)
- Memory leaks (retain cycles in closures, `[weak self]` missing)
- Missing image caching
- Unnecessary re-renders from incorrect `@Published` property granularity

### Swift Type Safety
- Force unwrapping (`!`) outside of tests
- Unsafe casts (`as!`) without fallback
- `Any` usage where generics or protocols would be safer
- Missing `Sendable` conformance on types crossing actor boundaries
- Incorrect `Optional` usage (non-optional where nil is genuinely impossible)

### Swift Concurrency
- Missing `await` keywords on async calls
- Unstructured concurrency (`Task {}` without cancellation handling)
- `DispatchQueue.main.async` instead of `@MainActor`
- Completion handlers where `async throws` should be used
- Missing `[weak self]` in `Task` closures that capture `self`
- Actors not used where shared mutable state exists

### Dead Code
- Unused `import` statements
- Unused functions, methods, and computed properties
- Unused variables and constants
- Unreachable code blocks (after `return`/`throw`)
- Unused files (not referenced from any other file)
- Unused Swift Package dependencies in `Package.swift`

**Detection approach for Swift:**
- Xcode compiler warnings flag most unused variables and imports automatically
- Use `grep` to find symbols declared but never referenced:
  ```bash
  # Find functions/methods defined but never called
  grep -rn "func " RickMortyPersistImage --include="*.swift" | grep -v "test\|Test\|override"
  ```
- Review Xcode's "unused" warnings in the build log

**Important:** Always verify findings manually before reporting. Check for:
- Protocol conformance methods (may look unused but satisfy a protocol)
- `@objc` methods called by Objective-C runtime
- Entry points (`@main`, scene delegates)
- Methods called via `#selector`

## Resources

See the reference documents for complete methodologies:

- `references/audit-methodology.md` - Full 6-phase audit process with detailed checklists
- `references/dead-code-methodology.md` - Dead code detection, verification, and cleanup workflows

## Quick Reference

### Before Starting
- [ ] Read `Package.swift` and `.xcodeproj` configuration
- [ ] Identify Swift Package dependencies
- [ ] Run `xcodebuild build` and `xcodebuild test` as baseline
- [ ] Run SwiftLint if configured
- [ ] Create file tracking list grouped by Clean Architecture layer

### During Audit
- [ ] Mark files as in-progress
- [ ] Analyze each category systematically
- [ ] Note specific file paths and line numbers
- [ ] Document before/after examples in Swift
- [ ] Mark files as completed

### After Audit
- [ ] Categorize all findings by priority
- [ ] Generate comprehensive report
- [ ] Save report to project root
- [ ] Provide brief console summary
