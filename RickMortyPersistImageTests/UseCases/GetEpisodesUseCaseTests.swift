import XCTest
@testable import RickMortyPersistImage

final class GetEpisodesUseCaseTests: XCTestCase {
    var sut: GetEpisodesUseCase!
    var mockRepository: MockEpisodeRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockEpisodeRepository()
        sut = GetEpisodesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testExecute_returnsEpisodesFromRepository() async throws {
        let episodes = MockDataFactory.makeEpisodeEntities(count: 4)
        mockRepository.fetchEpisodesResult = .success(
            MockDataFactory.makePagedResult(items: episodes, hasNextPage: true)
        )

        let result = try await sut.execute(page: 1)

        XCTAssertEqual(result.items.count, 4)
        XCTAssertTrue(result.hasNextPage)
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }

    func testExecute_propagatesRepositoryError() async {
        mockRepository.fetchEpisodesResult = .failure(NetworkError.serverError(statusCode: 500))

        do {
            _ = try await sut.execute(page: 1)
            XCTFail("Should have thrown")
        } catch let error as NetworkError {
            guard case .serverError(let code) = error else {
                return XCTFail("Wrong error case")
            }
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Wrong error type")
        }
    }
}
