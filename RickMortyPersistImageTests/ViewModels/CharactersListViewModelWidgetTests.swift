import XCTest
import Network
@testable import RickMortyPersistImage

@MainActor
final class CharactersListViewModelWidgetTests: XCTestCase {
    var sut: CharactersListViewModel!
    var mockRepository: MockCharacterRepository!
    var mockStore: MockAppGroupStore!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        mockStore = MockAppGroupStore()
        sut = CharactersListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: mockRepository),
            appGroupStore: mockStore
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockStore = nil
        super.tearDown()
    }

    // MARK: - Widget snapshot write

    func testLoadInitial_onSuccess_writesSnapshotToStore() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 5)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        XCTAssertEqual(mockStore.writeSnapshotCallCount, 1)
    }

    func testLoadInitial_onSuccess_writesAtMost20Characters() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 25)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        XCTAssertEqual(mockStore.writtenSnapshot?.count, 20)
    }

    func testLoadInitial_onSuccess_withPoolSmallerThan20_writesAllCharacters() async {
        let characters = MockDataFactory.makeCharacterEntities(count: 5)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters)
        )

        await sut.loadInitial()

        XCTAssertEqual(mockStore.writtenSnapshot?.count, 5)
    }

    func testLoadInitial_onFailure_doesNotWriteSnapshot() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.noInternetConnection)

        await sut.loadInitial()

        XCTAssertEqual(mockStore.writeSnapshotCallCount, 0)
    }

    func testRefresh_onSuccess_writesNewSnapshot() async {
        let first = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(MockDataFactory.makePagedResult(items: first))
        await sut.loadInitial()

        let second = MockDataFactory.makeCharacterEntities(count: 4)
        mockRepository.fetchCharactersResult = .success(MockDataFactory.makePagedResult(items: second))
        await sut.refresh()

        XCTAssertEqual(mockStore.writeSnapshotCallCount, 2)
    }

    func testLoadInitial_withNilStore_doesNotCrash() async {
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
