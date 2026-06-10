import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct GetLocationsUseCaseTests {
    let sut: GetLocationsUseCase
    let mockRepository: MockLocationRepository

    init() {
        mockRepository = MockLocationRepository()
        sut = GetLocationsUseCase(repository: mockRepository)
    }

    @Test
    func execute_delegatesToRepositoryWithCorrectPage() async throws {
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeLocationEntities(count: 2))
        )

        _ = try await sut.execute(page: 3)

        #expect(mockRepository.fetchCallCount == 1)
        #expect(mockRepository.lastFetchPage == 3)
    }

    @Test
    func execute_returnsCorrectNumberOfLocations() async throws {
        let locations = MockDataFactory.makeLocationEntities(count: 7)
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: locations, hasNextPage: false)
        )

        let result = try await sut.execute(page: 1)

        #expect(result.items.count == 7)
        #expect(!result.hasNextPage)
    }

    @Test
    func execute_whenNetworkFails_throwsError() async {
        mockRepository.fetchLocationsResult = .failure(NetworkError.noInternetConnection)

        await #expect(throws: (any Error).self) {
            try await sut.execute(page: 1)
        }
    }
}
