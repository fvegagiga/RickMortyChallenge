import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel
    @EnvironmentObject private var container: DIContainer

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                LoadingView()

            case .success(let character):
                detailContent(character)

            case .empty:
                EmptyStateView()

            case .failure(let error):
                ErrorView(error: error) {
                    Task { await viewModel.retry() }
                }
            }
        }
        .task { await viewModel.loadDetail() }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func detailContent(_ character: CharacterEntity) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection(character)
                infoSection(character)
            }
        }
        .navigationTitle(character.name)
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private func heroSection(_ character: CharacterEntity) -> some View {
        CachedAsyncImageView(
            url: character.imageURL,
            cacheManager: container.imageCacheManager
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.DS.cardBackground)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.DS.textTertiary)
                }
        }
        .frame(height: 340)
        .clipped()
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                StatusBadgeView(status: character.status)
                Text(character.name)
                    .font(.DS.largeTitle)
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
            .padding(DSSpacing.md)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.7), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 160),
                alignment: .bottom
            )
        }
    }

    @ViewBuilder
    private func infoSection(_ character: CharacterEntity) -> some View {
        VStack(spacing: DSSpacing.md) {
            infoRow(icon: "person.fill",       label: "Species",  value: character.species)
            infoRow(icon: "waveform.path.ecg", label: "Status",   value: character.status.displayName)
            infoRow(icon: "person.2.fill",     label: "Gender",   value: character.gender.displayName)
            infoRow(icon: "globe",             label: "Origin",   value: character.originName)
            infoRow(icon: "mappin.circle",     label: "Location", value: character.currentLocationName)

            if !character.type.isEmpty {
                infoRow(icon: "tag.fill", label: "Type", value: character.type)
            }

            infoRow(
                icon: "film.fill",
                label: "Episodes",
                value: "\(character.episodeURLs.count) episode(s)"
            )
        }
        .padding(DSSpacing.md)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.DS.portalGreen)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.DS.caption)
                    .foregroundStyle(Color.DS.textSecondary)
                Text(value)
                    .font(.DS.body)
                    .foregroundStyle(Color.DS.textPrimary)
            }

            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(Color.DS.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
    }
}
