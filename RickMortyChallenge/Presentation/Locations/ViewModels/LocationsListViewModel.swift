import Combine
import Foundation

@MainActor
final class LocationsListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[LocationEntity]> = .idle
    @Published private(set) var isLoadingMore = false

    private let getLocationsUseCase: GetLocationsUseCaseProtocol
    private var currentPage = 1
    private var hasNextPage = true
    private var allLocations: [LocationEntity] = []

    init(getLocationsUseCase: GetLocationsUseCaseProtocol) {
        self.getLocationsUseCase = getLocationsUseCase
    }

    func loadInitial() async {
        guard case .idle = viewState else { return }
        await performFetch(reset: true)
    }

    func refresh() async {
        await performFetch(reset: true)
    }

    func loadMoreIfNeeded(currentItem: LocationEntity) async {
        guard
            hasNextPage,
            !isLoadingMore,
            allLocations.last?.id == currentItem.id
        else { return }

        isLoadingMore = true
        currentPage += 1
        await performFetch(reset: false)
        isLoadingMore = false
    }

    private func performFetch(reset: Bool) async {
        if reset {
            currentPage = 1
            allLocations = []
            viewState = .loading
        }

        do {
            let result = try await getLocationsUseCase.execute(page: currentPage)
            allLocations += result.items
            hasNextPage = result.hasNextPage
            viewState = allLocations.isEmpty ? .empty : .success(allLocations)
        } catch {
            if allLocations.isEmpty {
                viewState = .failure(error)
            }
        }
    }
}
