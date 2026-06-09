import XCTest
import Network
@testable import RickMortyChallenge

@MainActor
final class CharacterDetailViewModelTests: XCTestCase {
    var sut: CharacterDetailViewModel!
    var mockRepository: MockCharacterRepository!
    var useCase: GetCharacterDetailUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        useCase = GetCharacterDetailUseCase(repository: mockRepository)
        sut = CharacterDetailViewModel(characterId: 42, getCharacterDetailUseCase: useCase)
    }

    override func tearDown() {
        sut = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadDetail_fetchesCorrectCharacterId() async {
        mockRepository.fetchCharacterDetailResult = .success(
            MockDataFactory.makeCharacterEntity(id: 42)
        )

        await sut.loadDetail()

        XCTAssertEqual(mockRepository.lastDetailId, 42)
    }

    func testLoadDetail_withSuccess_setsSuccessState() async {
        let character = MockDataFactory.makeCharacterEntity(id: 42, name: "Morty Smith")
        mockRepository.fetchCharacterDetailResult = .success(character)

        await sut.loadDetail()

        if case .success(let loaded) = sut.viewState {
            XCTAssertEqual(loaded.id, 42)
            XCTAssertEqual(loaded.name, "Morty Smith")
        } else {
            XCTFail("Expected .success state")
        }
    }

    func testLoadDetail_withError_setsFailureState() async {
        mockRepository.fetchCharacterDetailResult = .failure(NetworkError.notFound)

        await sut.loadDetail()

        if case .failure = sut.viewState { /* pass */ } else {
            XCTFail("Expected .failure state")
        }
    }

    func testLoadDetail_whenCalledTwice_onlyFetchesOnce() async {
        mockRepository.fetchCharacterDetailResult = .success(
            MockDataFactory.makeCharacterEntity(id: 42)
        )

        await sut.loadDetail()
        await sut.loadDetail()

        XCTAssertEqual(mockRepository.fetchDetailCallCount, 1)
    }

    func testRetry_resetsStateAndFetchesAgain() async {
        mockRepository.fetchCharacterDetailResult = .failure(NetworkError.notFound)
        await sut.loadDetail()

        mockRepository.fetchCharacterDetailResult = .success(
            MockDataFactory.makeCharacterEntity(id: 42)
        )
        await sut.retry()

        if case .success = sut.viewState { /* pass */ } else {
            XCTFail("Expected .success after retry")
        }
        XCTAssertEqual(mockRepository.fetchDetailCallCount, 2)
    }
}
