import Foundation
import Network

final class EpisodeRepositoryImpl: EpisodeRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let mapper: EpisodeMapper

    init(networkService: NetworkServiceProtocol, mapper: EpisodeMapper) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func fetchEpisodes(page: Int) async throws -> PagedResult<EpisodeEntity> {
        let response: PaginatedResponseDTO<EpisodeDTO> = try await networkService.fetch(
            APIEndpoint.episodes(page: page)
        )
        return PagedResult(
            items: mapper.map(response.results),
            hasNextPage: response.info.next != nil,
            totalCount: response.info.count
        )
    }
}
