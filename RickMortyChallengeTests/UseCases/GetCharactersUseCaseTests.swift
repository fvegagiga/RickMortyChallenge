import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct GetCharactersUseCaseTests {
    let sut: GetCharactersUseCase
    let mockRepository: MockCharacterRepository

    init() {
        mockRepository = MockCharacterRepository()
        sut = GetCharactersUseCase(repository: mockRepository)
    }

    @Test
    func execute_delegatesToRepositoryWithCorrectParameters() async throws {
        let characters = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters, hasNextPage: true)
        )

        _ = try await sut.execute(page: 2, name: "Rick")

        #expect(mockRepository.fetchCharactersCallCount == 1)
        #expect(mockRepository.lastFetchPage == 2)
        #expect(mockRepository.lastFetchName == "Rick")
    }

    @Test
    func execute_returnsPagedResultFromRepository() async throws {
        let characters = MockDataFactory.makeCharacterEntities(count: 5)
        let expected = MockDataFactory.makePagedResult(items: characters, hasNextPage: true)
        mockRepository.fetchCharactersResult = .success(expected)

        let result = try await sut.execute(page: 1, name: nil)

        #expect(result.items.count == 5)
        #expect(result.hasNextPage)
    }

    @Test
    func execute_whenRepositoryThrows_propagatesError() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.notFound)

        await #expect(throws: NetworkError.notFound) {
            try await sut.execute(page: 1, name: nil)
        }
    }

    @Test
    func execute_withNilName_passesNilToRepository() async throws {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: [])
        )

        _ = try await sut.execute(page: 1, name: nil)

        #expect(mockRepository.lastFetchName == nil)
    }
}
