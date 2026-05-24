import Foundation

protocol GetLocationsUseCaseProtocol {
    func execute(page: Int) async throws -> PagedResult<LocationEntity>
}

final class GetLocationsUseCase: GetLocationsUseCaseProtocol {
    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> PagedResult<LocationEntity> {
        try await repository.fetchLocations(page: page)
    }
}
