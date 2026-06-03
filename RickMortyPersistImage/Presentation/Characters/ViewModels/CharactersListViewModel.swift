import Combine
import Foundation

@MainActor
final class CharactersListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<[CharacterEntity]> = .idle
    @Published private(set) var isLoadingMore = false
    @Published var searchText = ""

    private let getCharactersUseCase: GetCharactersUseCaseProtocol
    private let appGroupStore: AppGroupStoreProtocol?
    private var currentPage = 1
    private var hasNextPage = true
    private var allCharacters: [CharacterEntity] = []
    private var searchDebounceTask: Task<Void, Never>?

    init(
        getCharactersUseCase: GetCharactersUseCaseProtocol,
        appGroupStore: AppGroupStoreProtocol? = nil
    ) {
        self.getCharactersUseCase = getCharactersUseCase
        self.appGroupStore = appGroupStore
    }

    func loadInitial() async {
        guard case .idle = viewState else { return }
        await performFetch(reset: true)
    }

    func refresh() async {
        searchDebounceTask?.cancel()
        await performFetch(reset: true)
    }

    func loadMoreIfNeeded(currentItem: CharacterEntity) async {
        guard
            hasNextPage,
            !isLoadingMore,
            allCharacters.last?.id == currentItem.id
        else { return }

        isLoadingMore = true
        currentPage += 1
        await performFetch(reset: false)
        isLoadingMore = false
    }

    func onSearchTextChanged() {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    // MARK: - Private

    private func performFetch(reset: Bool) async {
        if reset {
            currentPage = 1
            allCharacters = []
            viewState = .loading
        }

        let query = searchText.trimmingCharacters(in: .whitespaces)

        do {
            let result = try await getCharactersUseCase.execute(
                page: currentPage,
                name: query.isEmpty ? nil : query
            )
            allCharacters += result.items
            hasNextPage = result.hasNextPage

            viewState = allCharacters.isEmpty ? .empty : .success(allCharacters)
            writeWidgetSnapshot()
        } catch {
            if allCharacters.isEmpty {
                viewState = .failure(error)
            }
        }
    }

    private func writeWidgetSnapshot() {
        guard let store = appGroupStore else { return }
        let snapshot = Array(allCharacters.shuffled().prefix(20)).map {
            CharacterWidgetData(id: $0.id, name: $0.name, imageFileName: "\($0.id).jpg", imageURL: $0.imageURL)
        }
        store.writeSnapshot(snapshot)
        Task.detached(priority: .background) {
            await store.downloadImages(for: snapshot)
        }
    }

    private func performSearch() async {
        currentPage = 1
        let query = searchText.trimmingCharacters(in: .whitespaces)

        do {
            let result = try await getCharactersUseCase.execute(
                page: currentPage,
                name: query.isEmpty ? nil : query
            )
            hasNextPage = result.hasNextPage
            allCharacters = result.items

            viewState = allCharacters.isEmpty ? .empty : .success(allCharacters)
        } catch {
            if allCharacters.isEmpty {
                viewState = .failure(error)
            }
        }
    }
}
