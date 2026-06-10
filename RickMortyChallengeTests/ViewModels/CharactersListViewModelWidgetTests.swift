import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct CharactersListViewModelWidgetTests {
    let sut: CharactersListViewModel
    let mockRepository: MockCharacterRepository
    let mockStore: MockAppGroupStore

    init() {
        mockRepository = MockCharacterRepository()
        mockStore = MockAppGroupStore()
        sut = CharactersListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: mockRepository),
            appGroupStore: mockStore
        )
    }

    @Test
    func loadInitial_onSuccess_writesSnapshotToStore() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 5)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        #expect(mockStore.writeSnapshotCallCount == 1)
    }

    @Test
    func loadInitial_onSuccess_writesAtMost20Characters() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 25)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        #expect(mockStore.writtenSnapshot?.count == 20)
    }

    @Test
    func loadInitial_onSuccess_withPoolSmallerThan20_writesAllCharacters() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 5)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        #expect(mockStore.writtenSnapshot?.count == 5)
    }

    @Test
    func loadInitial_onFailure_doesNotWriteSnapshot() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.noInternetConnection)

        await sut.loadInitial()

        #expect(mockStore.writeSnapshotCallCount == 0)
    }

    @Test
    func refresh_onSuccess_writesNewSnapshot() async {
        let first = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(MockDataFactory.makePagedResult(items: first))
        await sut.loadInitial()

        let second = MockDataFactory.makeCharacterEntities(count: 4)
        mockRepository.fetchCharactersResult = .success(MockDataFactory.makePagedResult(items: second))
        await sut.refresh()

        #expect(mockStore.writeSnapshotCallCount == 2)
    }

    @Test
    func loadInitial_onSuccess_snapshotIncludesCharacterStatus() async {
        let characters = [MockDataFactory.makeCharacterEntity(id: 1, name: "Rick", status: .alive)]
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        #expect(mockStore.writtenSnapshot?.first?.status == CharacterStatus.alive.rawValue)
    }

    @Test
    func loadInitial_withNilStore_doesNotCrash() async {
        let sutWithoutStore = CharactersListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: mockRepository),
            appGroupStore: nil
        )
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeCharacterEntities(count: 3))
        )

        await sutWithoutStore.loadInitial()
    }
}
