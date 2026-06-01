import XCTest
import Network
@testable import RickMortyPersistImage

@MainActor
final class CharactersListViewModelTests: XCTestCase {
    var sut: CharactersListViewModel!
    var mockRepository: MockCharacterRepository!
    var useCase: GetCharactersUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        useCase = GetCharactersUseCase(repository: mockRepository)
        sut = CharactersListViewModel(getCharactersUseCase: useCase)
    }

    override func tearDown() {
        sut = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - loadInitial

    func testLoadInitial_startsFromIdleState() async {
        // Verify initial state is .idle before loading
        if case .idle = sut.viewState { /* pass */ } else {
            XCTFail("Expected .idle initial state")
        }
    }

    func testLoadInitial_withSuccessfulResponse_setsSuccessState() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters, hasNextPage: true)
        )

        await sut.loadInitial()

        if case .success(let loaded) = sut.viewState {
            XCTAssertEqual(loaded.count, 3)
            XCTAssertEqual(loaded.first?.name, "Character 1")
        } else {
            XCTFail("Expected .success state, got \(sut.viewState)")
        }
    }

    func testLoadInitial_withEmptyResponse_setsEmptyState() async {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: [], hasNextPage: false)
        )

        await sut.loadInitial()

        if case .empty = sut.viewState { /* pass */ } else {
            XCTFail("Expected .empty state")
        }
    }

    func testLoadInitial_withNetworkError_setsFailureState() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.noInternetConnection)

        await sut.loadInitial()

        if case .failure = sut.viewState { /* pass */ } else {
            XCTFail("Expected .failure state")
        }
    }

    func testLoadInitial_whenCalledTwice_onlyFetchesOnce() async {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeCharacterEntities(count: 1))
        )

        await sut.loadInitial()
        await sut.loadInitial()

        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1)
    }

    // MARK: - refresh

    func testRefresh_resetsAndFetchesAgain() async {
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
            XCTAssertEqual(loaded.count, 5)
        } else {
            XCTFail("Expected .success after refresh")
        }
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 2)
    }

    // MARK: - pagination

    func testLoadMoreIfNeeded_whenCalledWithLastItem_fetchesNextPage() async {
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

        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 2)
        XCTAssertEqual(mockRepository.lastFetchPage, 2)
        if case .success(let all) = sut.viewState {
            XCTAssertEqual(all.count, 6)
        } else {
            XCTFail("Expected .success with combined pages")
        }
    }

    func testLoadMoreIfNeeded_whenNotLastItem_doesNotFetch() async {
        let items = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: items, hasNextPage: true)
        )
        await sut.loadInitial()
        let callCountAfterInitial = mockRepository.fetchCharactersCallCount

        await sut.loadMoreIfNeeded(currentItem: items[0])

        XCTAssertEqual(mockRepository.fetchCharactersCallCount, callCountAfterInitial)
    }
}
