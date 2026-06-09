import XCTest
@testable import RickMortyChallenge

@MainActor
final class LocationsListViewModelTests: XCTestCase {
    var sut: LocationsListViewModel!
    var mockRepository: MockLocationRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockLocationRepository()
        sut = LocationsListViewModel(
            getLocationsUseCase: GetLocationsUseCase(repository: mockRepository)
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadInitial_withSuccess_setsSuccessState() async {
        let locations = MockDataFactory.makeLocationEntities(count: 4)
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: locations, hasNextPage: false)
        )

        await sut.loadInitial()

        if case .success(let loaded) = sut.viewState {
            XCTAssertEqual(loaded.count, 4)
        } else {
            XCTFail("Expected .success state")
        }
    }

    func testLoadInitial_whenNoLocations_setsEmptyState() async {
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: [], hasNextPage: false)
        )

        await sut.loadInitial()

        if case .empty = sut.viewState { /* pass */ } else {
            XCTFail("Expected .empty state")
        }
    }

    func testRefresh_replacesExistingData() async {
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: MockDataFactory.makeLocationEntities(count: 2))
        )
        await sut.loadInitial()

        let newLocations = MockDataFactory.makeLocationEntities(count: 8)
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: newLocations)
        )
        await sut.refresh()

        if case .success(let loaded) = sut.viewState {
            XCTAssertEqual(loaded.count, 8)
        } else {
            XCTFail("Expected .success with refreshed data")
        }
    }
}
