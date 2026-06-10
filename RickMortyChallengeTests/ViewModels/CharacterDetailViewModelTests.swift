import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct CharacterDetailViewModelTests {
    let sut: CharacterDetailViewModel
    let mockRepository: MockCharacterRepository

    init() {
        mockRepository = MockCharacterRepository()
        let useCase = GetCharacterDetailUseCase(repository: mockRepository)
        sut = CharacterDetailViewModel(characterId: 42, getCharacterDetailUseCase: useCase)
    }

    @Test
    func loadDetail_fetchesCorrectCharacterId() async {
        mockRepository.fetchCharacterDetailResult = .success(
            MockDataFactory.makeCharacterEntity(id: 42)
        )

        await sut.loadDetail()

        #expect(mockRepository.lastDetailId == 42)
    }

    @Test
    func loadDetail_withSuccess_setsSuccessState() async {
        let character = MockDataFactory.makeCharacterEntity(id: 42, name: "Morty Smith")
        mockRepository.fetchCharacterDetailResult = .success(character)

        await sut.loadDetail()

        if case .success(let loaded) = sut.viewState {
            #expect(loaded.id == 42)
            #expect(loaded.name == "Morty Smith")
        } else {
            Issue.record("Expected .success state")
        }
    }

    @Test
    func loadDetail_withError_setsFailureState() async {
        mockRepository.fetchCharacterDetailResult = .failure(NetworkError.notFound)

        await sut.loadDetail()

        if case .failure = sut.viewState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected .failure state")
        }
    }

    @Test
    func loadDetail_whenCalledTwice_onlyFetchesOnce() async {
        mockRepository.fetchCharacterDetailResult = .success(
            MockDataFactory.makeCharacterEntity(id: 42)
        )

        await sut.loadDetail()
        await sut.loadDetail()

        #expect(mockRepository.fetchDetailCallCount == 1)
    }

    @Test
    func retry_resetsStateAndFetchesAgain() async {
        mockRepository.fetchCharacterDetailResult = .failure(NetworkError.notFound)
        await sut.loadDetail()

        mockRepository.fetchCharacterDetailResult = .success(
            MockDataFactory.makeCharacterEntity(id: 42)
        )
        await sut.retry()

        if case .success = sut.viewState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected .success after retry")
        }
        #expect(mockRepository.fetchDetailCallCount == 2)
    }
}
