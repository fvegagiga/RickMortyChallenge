import Foundation
import Network

final class LocationRepositoryImpl: LocationRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let mapper: LocationMapper

    init(networkService: NetworkServiceProtocol, mapper: LocationMapper) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func fetchLocations(page: Int) async throws -> PagedResult<LocationEntity> {
        let response: PaginatedResponseDTO<LocationDTO> = try await networkService.fetch(
            APIEndpoint.locations(page: page)
        )
        return PagedResult(
            items: mapper.map(response.results),
            hasNextPage: response.info.next != nil,
            totalCount: response.info.count
        )
    }
}
