import Combine
import Foundation

@MainActor
final class EpisodesListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[EpisodeEntity]> = .idle
    @Published private(set) var isLoadingMore = false

    private let getEpisodesUseCase: GetEpisodesUseCaseProtocol
    private var currentPage = 1
    private var hasNextPage = true
    private var allEpisodes: [EpisodeEntity] = []

    init(getEpisodesUseCase: GetEpisodesUseCaseProtocol) {
        self.getEpisodesUseCase = getEpisodesUseCase
    }

    func loadInitial() async {
        guard case .idle = viewState else { return }
        await performFetch(reset: true)
    }

    func refresh() async {
        await performFetch(reset: true)
    }

    func loadMoreIfNeeded(currentItem: EpisodeEntity) async {
        guard
            hasNextPage,
            !isLoadingMore,
            allEpisodes.last?.id == currentItem.id
        else { return }

        isLoadingMore = true
        currentPage += 1
        await performFetch(reset: false)
        isLoadingMore = false
    }

    private func performFetch(reset: Bool) async {
        if reset {
            currentPage = 1
            allEpisodes = []
            viewState = .loading
        }

        do {
            let result = try await getEpisodesUseCase.execute(page: currentPage)
            allEpisodes += result.items
            hasNextPage = result.hasNextPage
            viewState = allEpisodes.isEmpty ? .empty : .success(allEpisodes)
        } catch {
            if allEpisodes.isEmpty {
                viewState = .failure(error)
            }
        }
    }
}
