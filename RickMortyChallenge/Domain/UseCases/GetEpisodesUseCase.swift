import Foundation

protocol GetEpisodesUseCaseProtocol {
    func execute(page: Int) async throws -> PagedResult<EpisodeEntity>
}

final class GetEpisodesUseCase: GetEpisodesUseCaseProtocol {
    private let repository: EpisodeRepositoryProtocol

    init(repository: EpisodeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> PagedResult<EpisodeEntity> {
        try await repository.fetchEpisodes(page: page)
    }
}
