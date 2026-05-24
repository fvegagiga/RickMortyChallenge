import SwiftUI

struct LocationsListView: View {
    @StateObject private var viewModel: LocationsListViewModel

    init(viewModel: LocationsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            contentView
                .navigationTitle("Locations")
                .task { await viewModel.loadInitial() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()

        case .success(let locations):
            List {
                ForEach(locations) { location in
                    LocationRowView(location: location)
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: location)
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
                icon: "globe.slash",
                title: "No Locations Found",
                subtitle: "There are no locations to display."
            )

        case .failure(let error):
            ErrorView(error: error) {
                Task { await viewModel.refresh() }
            }
        }
    }
}
