import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct CharactersListViewModelTests {
    let sut: CharactersListViewModel
    let mockRepository: MockCharacterRepository

    init() {
        mockRepository = MockCharacterRepository()
        let useCase = GetCharactersUseCase(repository: mockRepository)
        sut = CharactersListViewModel(getCharactersUseCase: useCase)
    }

    @Test
    func loadInitial_startsFromIdleState() async {
        if case .idle = sut.viewState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected .idle initial state")
        }
    }

    @Test
    func loadInitial_withSuccessfulResponse_setsSuccessState() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters, hasNextPage: true)
        )

        await sut.loadInitial()

        if case .success(let loaded) = sut.viewState {
            #expect(loaded.count == 3)
            #expect(loaded.first?.name == "Character 1")
        } else {
            Issue.record("Expected .success state, got \(sut.viewState)")
        }
    }

    @Test
    func loadInitial_withEmptyResponse_setsEmptyState() async {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: [], hasNextPage: false)
        )

        await sut.loadInitial()

        if case .empty = sut.viewState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected .empty state")
        }
    }

    @Test
    func loadInitial_withNetworkError_setsFailureState() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.noInternetConnection)

        await sut.loadInitial()

        if case .failure = sut.viewState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected .failure state")
        }
    }

    @Test
    func loadInitial_whenCalledTwice_onlyFetchesOnce() async {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeCharacterEntities(count: 1))
        )

        await sut.loadInitial()
        await sut.loadInitial()

        #expect(mockRepository.fetchCharactersCallCount == 1)
    }

    @Test
    func refresh_resetsAndFetchesAgain() async {
        let firstBatch = MockDataFactory.makeCharacterEntities(count: 2)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: firstBatch)
        )
        await sut.loadInitial()

        let secondBatch = MockDataFactory.makeCharacterEntities(count: 5)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: secondBatch)
        )
        await sut.refresh()

        if case .success(let loaded) = sut.viewState {
            #expect(loaded.count == 5)
        } else {
            Issue.record("Expected .success after refresh")
        }
        #expect(mockRepository.fetchCharactersCallCount == 2)
    }

    @Test
    func loadMoreIfNeeded_whenCalledWithLastItem_fetchesNextPage() async {
        let firstPage = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: firstPage, hasNextPage: true)
        )
        await sut.loadInitial()

        let secondPage = MockDataFactory.makeCharacterEntities(count: 3).map {
            MockDataFactory.makeCharacterEntity(id: $0.id + 100, name: $0.name + " p2")
        }
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: secondPage, hasNextPage: false)
        )

        await sut.loadMoreIfNeeded(currentItem: firstPage.last!)

        #expect(mockRepository.fetchCharactersCallCount == 2)
        #expect(mockRepository.lastFetchPage == 2)
        if case .success(let all) = sut.viewState {
            #expect(all.count == 6)
        } else {
            Issue.record("Expected .success with combined pages")
        }
    }

    @Test
    func loadMoreIfNeeded_whenNotLastItem_doesNotFetch() async {
        let items = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: items, hasNextPage: true)
        )
        await sut.loadInitial()
        let callCountAfterInitial = mockRepository.fetchCharactersCallCount

        await sut.loadMoreIfNeeded(currentItem: items[0])

        #expect(mockRepository.fetchCharactersCallCount == callCountAfterInitial)
    }

    @Test
    func onSearchTextChanged_cancelsPriorDebounce() async {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeCharacterEntities(count: 3))
        )
        await sut.loadInitial()
        let callCountAfterInitial = mockRepository.fetchCharactersCallCount

        sut.searchText = "Rick"
        sut.onSearchTextChanged()
        sut.searchText = "Rick S"
        sut.onSearchTextChanged()

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockRepository.fetchCharactersCallCount == callCountAfterInitial)
    }

    private func waitForFetchCount(_ expected: Int, timeoutNanoseconds: UInt64 = 2_000_000_000) async {
        let step: UInt64 = 50_000_000
        var elapsed: UInt64 = 0
        while mockRepository.fetchCharactersCallCount < expected, elapsed < timeoutNanoseconds {
            await Task.yield()
            try? await Task.sleep(nanoseconds: step)
            elapsed += step
        }
    }

    @Test
    func onSearchTextChanged_triggersSearchAfterDebounce() async {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeCharacterEntities(count: 3))
        )
        await sut.loadInitial()

        let searchResults = [MockDataFactory.makeCharacterEntity(id: 99, name: "Rick")]
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: searchResults)
        )

        sut.searchText = "Rick"
        sut.onSearchTextChanged()

        await waitForFetchCount(2)

        #expect(mockRepository.fetchCharactersCallCount == 2)
        if case .success(let loaded) = sut.viewState {
            #expect(loaded.count == 1)
            #expect(loaded.first?.name == "Rick")
        } else {
            Issue.record("Expected .success after debounced search")
        }
    }
}
