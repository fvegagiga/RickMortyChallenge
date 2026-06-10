import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct GetCharacterDetailUseCaseTests {
    let sut: GetCharacterDetailUseCase
    let mockRepository: MockCharacterRepository

    init() {
        mockRepository = MockCharacterRepository()
        sut = GetCharacterDetailUseCase(repository: mockRepository)
    }

    @Test
    func execute_delegatesToRepositoryWithCorrectId() async throws {
        let character = MockDataFactory.makeCharacterEntity(id: 99)
        mockRepository.fetchCharacterDetailResult = .success(character)

        let result = try await sut.execute(id: 99)

        #expect(mockRepository.fetchDetailCallCount == 1)
        #expect(mockRepository.lastDetailId == 99)
        #expect(result.id == 99)
    }

    @Test
    func execute_whenRepositoryThrows_propagatesError() async {
        mockRepository.fetchCharacterDetailResult = .failure(NetworkError.notFound)

        await #expect(throws: NetworkError.notFound) {
            try await sut.execute(id: 1)
        }
    }
}
