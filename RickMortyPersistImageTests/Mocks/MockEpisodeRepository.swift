import Foundation
@testable import RickMortyPersistImage

final class MockEpisodeRepository: EpisodeRepositoryProtocol {
    var fetchEpisodesResult: Result<PagedResult<EpisodeEntity>, Error> = .success(
        MockDataFactory.makePagedResult(items: [])
    )
    private(set) var fetchCallCount = 0
    private(set) var lastFetchPage: Int?

    func fetchEpisodes(page: Int) async throws -> PagedResult<EpisodeEntity> {
        fetchCallCount += 1
        lastFetchPage = page
        return try fetchEpisodesResult.get()
    }
}
