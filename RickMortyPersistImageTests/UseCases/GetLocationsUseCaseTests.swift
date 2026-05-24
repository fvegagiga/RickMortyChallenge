import XCTest
@testable import RickMortyPersistImage

final class GetLocationsUseCaseTests: XCTestCase {
    var sut: GetLocationsUseCase!
    var mockRepository: MockLocationRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockLocationRepository()
        sut = GetLocationsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testExecute_delegatesToRepositoryWithCorrectPage() async throws {
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeLocationEntities(count: 2))
        )

        _ = try await sut.execute(page: 3)

        XCTAssertEqual(mockRepository.fetchCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPage, 3)
    }

    func testExecute_returnsCorrectNumberOfLocations() async throws {
        let locations = MockDataFactory.makeLocationEntities(count: 7)
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: locations, hasNextPage: false)
        )

        let result = try await sut.execute(page: 1)

        XCTAssertEqual(result.items.count, 7)
        XCTAssertFalse(result.hasNextPage)
    }

    func testExecute_whenNetworkFails_throwsError() async {
        mockRepository.fetchLocationsResult = .failure(NetworkError.noInternetConnection)

        do {
            _ = try await sut.execute(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
