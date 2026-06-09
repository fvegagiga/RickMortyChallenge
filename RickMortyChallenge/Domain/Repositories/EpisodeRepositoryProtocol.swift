import Foundation

protocol EpisodeRepositoryProtocol {
    func fetchEpisodes(page: Int) async throws -> PagedResult<EpisodeEntity>
}
