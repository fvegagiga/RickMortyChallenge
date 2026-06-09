import SwiftUI

struct EpisodesListView: View {
    @StateObject private var viewModel: EpisodesListViewModel

    init(viewModel: EpisodesListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            contentView
                .navigationTitle("Episodes")
                .task { await viewModel.loadInitial() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()

        case .success(let episodes):
            List {
                ForEach(episodes) { episode in
                    EpisodeRowView(episode: episode)
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: episode)
                        }
                }

                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color.DS.portalGreen)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)

        case .empty:
            EmptyStateView(
                icon: "film",
                title: "No Episodes Found",
                subtitle: "There are no episodes to display."
            )

        case .failure(let error):
            ErrorView(error: error) {
                Task { await viewModel.refresh() }
            }
        }
    }
}
