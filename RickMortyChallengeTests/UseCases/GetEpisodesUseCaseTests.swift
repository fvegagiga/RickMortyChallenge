import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct GetEpisodesUseCaseTests {
    let sut: GetEpisodesUseCase
    let mockRepository: MockEpisodeRepository

    init() {
        mockRepository = MockEpisodeRepository()
        sut = GetEpisodesUseCase(repository: mockRepository)
    }

    @Test
    func execute_returnsEpisodesFromRepository() async throws {
        let episodes = MockDataFactory.makeEpisodeEntities(count: 4)
        mockRepository.fetchEpisodesResult = .success(
            MockDataFactory.makePagedResult(items: episodes, hasNextPage: true)
        )

        let result = try await sut.execute(page: 1)

        #expect(result.items.count == 4)
        #expect(result.hasNextPage)
        #expect(mockRepository.fetchCallCount == 1)
    }

    @Test
    func execute_propagatesRepositoryError() async {
        mockRepository.fetchEpisodesResult = .failure(NetworkError.serverError(statusCode: 500))

        await #expect(throws: NetworkError.self) {
            try await sut.execute(page: 1)
        }
    }
}
