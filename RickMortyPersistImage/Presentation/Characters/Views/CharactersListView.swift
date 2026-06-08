import SwiftUI

struct CharactersListView: View {
    @StateObject private var viewModel: CharactersListViewModel
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var container: DIContainer

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.sm),
        GridItem(.flexible(), spacing: DSSpacing.sm)
    ]

    init(viewModel: CharactersListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $router.characterPath) {
            contentView
                .navigationTitle("Characters")
                .searchable(text: $viewModel.searchText, prompt: "Search by name…")
                .onChange(of: viewModel.searchText) { _ in viewModel.onSearchTextChanged() }
                .task { await viewModel.loadInitial() }
                .refreshable { await viewModel.refresh() }
                .navigationDestination(for: CharacterRoute.self) { route in
                    switch route {
                    case .detail(let id):
                        CharacterDetailView(
                            viewModel: container.makeCharacterDetailViewModel(id: id)
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()

        case .success(let characters):
            ScrollView {
                LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                    ForEach(characters) { character in
                        Button {
                            router.pushCharacter(.detail(id: character.id))
                        } label: {
                            CharacterCardView(
                                character: character,
                                cacheManager: container.imageCacheManager
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("character-card")
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: character)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: characters.map(\.id))

                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(Color.DS.portalGreen)
                        .padding(.vertical, DSSpacing.md)
                }
            }

        case .empty:
            EmptyStateView(
                icon: "person.slash",
                title: "No Characters Found",
                subtitle: "Try a different name."
            )

        case .failure(let error):
            ErrorView(error: error) {
                Task { await viewModel.refresh() }
            }
        }
    }
}
