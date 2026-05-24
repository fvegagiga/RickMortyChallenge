import Foundation

protocol LocationRepositoryProtocol {
    func fetchLocations(page: Int) async throws -> PagedResult<LocationEntity>
}
