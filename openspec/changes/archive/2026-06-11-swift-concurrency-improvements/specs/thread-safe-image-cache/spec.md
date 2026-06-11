## ADDED Requirements

### Requirement: Image cache access is actor-isolated

The image cache implementation (`ImageCacheManager`) SHALL be declared as an `actor` so all reads and writes to in-memory (`NSCache`) and on-disk cache state are serialized through Swift concurrency isolation.

#### Scenario: Concurrent read and write do not race

- **WHEN** multiple callers request `image(for:)` and `store(_:for:)` concurrently for the same or different URLs
- **THEN** the cache SHALL process each operation sequentially without data races on shared mutable state

#### Scenario: Disk writes occur off the caller's synchronous critical section

- **WHEN** an image is stored via the cache API
- **THEN** disk persistence MAY occur asynchronously inside the actor's isolation domain without exposing unsynchronized `NSCache` or file path mutation to external callers

### Requirement: Image cache protocol exposes async APIs

`ImageCacheManagerProtocol` SHALL declare `async` methods for cache lookup, store, and clear operations so callers crossing actor boundaries use `await` explicitly.

#### Scenario: CachedAsyncImageView loads through async cache API

- **WHEN** `CachedAsyncImageView` loads an image for a URL
- **THEN** it SHALL `await` the cache lookup before falling back to network fetch and SHALL `await` cache store after a successful download

#### Scenario: DIContainer provides the actor instance

- **WHEN** the app composition root creates dependencies
- **THEN** `DIContainer` SHALL expose the shared `ImageCacheManager` actor instance as `ImageCacheManagerProtocol` for injection into views

### Requirement: Cache behaviour is preserved

The actor-isolated cache SHALL preserve existing two-tier caching semantics: memory hit → disk hit → miss, with the same cache directory naming, count limit (150), and total cost limit (75 MB).

#### Scenario: Memory hit returns without disk read

- **WHEN** an image exists in the in-memory cache for a URL
- **THEN** `image(for:)` SHALL return the cached image without reading from disk

#### Scenario: Disk hit promotes to memory

- **WHEN** an image exists on disk but not in memory
- **THEN** `image(for:)` SHALL load from disk, populate the memory cache, and return the image

#### Scenario: Clear cache removes memory and disk entries

- **WHEN** `clearCache()` is invoked
- **THEN** the memory cache SHALL be emptied and the on-disk cache directory SHALL be recreated empty

### Requirement: Concurrency tests cover cache isolation

The test suite SHALL include Swift Testing cases that exercise concurrent cache access and verify correctness under parallel load.

#### Scenario: Parallel stores and reads complete without crash

- **WHEN** a test performs concurrent `store` and `image(for:)` operations across a task group
- **THEN** all tasks SHALL complete and the final cached value for each URL SHALL match the last stored image data
