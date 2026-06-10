import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct LocationsListViewModelTests {
    let sut: LocationsListViewModel
    let mockRepository: MockLocationRepository

    init() {
        mockRepository = MockLocationRepository()
        sut = LocationsListViewModel(
            getLocationsUseCase: GetLocationsUseCase(repository: mockRepository)
        )
    }

    @Test
    func loadInitial_withSuccess_setsSuccessState() async {
        let locations = MockDataFactory.makeLocationEntities(count: 4)
        mockRepository.fetchLocationsResult = .success(
            MockDataFactory.makePagedResult(items: locations, hasNextPage: false)
        )

        await sut.loadInitial()

        if case .success(let loaded) = sut.viewState {
            #expect(loaded.count == 4)
        } else {
            Issue.record("Expected .success state")
        }
    }

    @Test
    func loadInitial_whenNoLocations_setsEmptyState() async {
        mockRepository.fetchLocationsResult = .success(
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
    func refresh_replacesExistingData() async {
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
            #expect(loaded.count == 8)
        } else {
            Issue.record("Expected .success with refreshed data")
        }
    }
}
