import Foundation
import Network

final class CharacterRepositoryImpl: CharacterRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let mapper: CharacterMapper

    init(networkService: NetworkServiceProtocol, mapper: CharacterMapper) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func fetchCharacters(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        let response: PaginatedResponseDTO<CharacterDTO> = try await networkService.fetch(
            APIEndpoint.characters(page: page, name: name)
        )
        return PagedResult(
            items: mapper.map(response.results),
            hasNextPage: response.info.next != nil,
            totalCount: response.info.count
        )
    }

    func fetchCharacterDetail(id: Int) async throws -> CharacterEntity {
        let dto: CharacterDTO = try await networkService.fetch(APIEndpoint.characterDetail(id: id))
        return mapper.map(dto)
    }
}
