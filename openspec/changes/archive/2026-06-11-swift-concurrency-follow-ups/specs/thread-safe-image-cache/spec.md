## MODIFIED Requirements

### Requirement: Concurrency tests cover cache isolation

The test suite SHALL include Swift Testing cases that exercise concurrent cache access and verify correctness under parallel load.

#### Scenario: Parallel stores and reads complete without crash

- **WHEN** a test performs concurrent `store` and `image(for:)` operations across a task group
- **THEN** all tasks SHALL complete and the final cached value for each URL SHALL match the last stored image data

## ADDED Requirements

### Requirement: Test-only cache helpers are not production-visible

Test-only methods on `ImageCacheManager` (such as `clearMemoryCacheForTesting()`) SHALL NOT be part of the public production API surface.

#### Scenario: clearMemoryCacheForTesting is debug-only

- **WHEN** building a Release configuration of the app target
- **THEN** `clearMemoryCacheForTesting()` SHALL NOT be available on `ImageCacheManager`
