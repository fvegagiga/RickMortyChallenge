import Foundation
@testable import RickMortyChallenge

final class MockLocationRepository: LocationRepositoryProtocol {
    var fetchLocationsResult: Result<PagedResult<LocationEntity>, Error> = .success(
        MockDataFactory.makePagedResult(items: [])
    )
    private(set) var fetchCallCount = 0
    private(set) var lastFetchPage: Int?

    func fetchLocations(page: Int) async throws -> PagedResult<LocationEntity> {
        fetchCallCount += 1
        lastFetchPage = page
        return try fetchLocationsResult.get()
    }
}
