import XCTest
@testable import RickMortyPersistImage

@MainActor
final class GetCharactersUseCaseTests: XCTestCase {
    var sut: GetCharactersUseCase!
    var mockRepository: MockCharacterRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        sut = GetCharactersUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testExecute_delegatesToRepositoryWithCorrectParameters() async throws {
        let characters = MockDataFactory.makeCharacterEntities(count: 3)
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: characters, hasNextPage: true)
        )

        _ = try await sut.execute(page: 2, name: "Rick")

        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPage, 2)
        XCTAssertEqual(mockRepository.lastFetchName, "Rick")
    }

    func testExecute_returnsPagedResultFromRepository() async throws {
        let characters = MockDataFactory.makeCharacterEntities(count: 5)
        let expected = MockDataFactory.makePagedResult(items: characters, hasNextPage: true)
        mockRepository.fetchCharactersResult = .success(expected)

        let result = try await sut.execute(page: 1, name: nil)

        XCTAssertEqual(result.items.count, 5)
        XCTAssertTrue(result.hasNextPage)
    }

    func testExecute_whenRepositoryThrows_propagatesError() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.notFound)

        do {
            _ = try await sut.execute(page: 1, name: nil)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.notFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testExecute_withNilName_passesNilToRepository() async throws {
        mockRepository.fetchCharactersResult = .success(
            MockDataFactory.makePagedResult(items: [])
        )

        _ = try await sut.execute(page: 1, name: nil)

        XCTAssertNil(mockRepository.lastFetchName)
    }
}
