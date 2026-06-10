import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct LocationRepositoryTests {
    let sut: LocationRepositoryImpl
    let mockNetworkService: MockNetworkService

    init() {
        mockNetworkService = MockNetworkService()
        sut = LocationRepositoryImpl(networkService: mockNetworkService, mapper: LocationMapper())
    }

    @Test
    func fetchLocations_withValidResponse_returnsMappedEntities() async throws {
        let dto = makeLocationDTO(id: 8, name: "Citadel of Ricks")
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
            results: [dto]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchLocations(page: 1)

        #expect(result.items.count == 1)
        #expect(result.items.first?.id == 8)
        #expect(result.items.first?.name == "Citadel of Ricks")
        #expect(!result.hasNextPage)
    }

    @Test
    func fetchLocations_whenNextPageExists_hasNextPageIsTrue() async throws {
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 126, pages: 7, next: "https://rickandmortyapi.com/api/location?page=2", prev: nil),
            results: [makeLocationDTO()]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchLocations(page: 1)

        #expect(result.hasNextPage)
        #expect(result.totalCount == 126)
    }

    @Test
    func fetchLocations_whenNetworkThrows_propagatesError() async {
        mockNetworkService.errorToThrow = NetworkError.noInternetConnection

        await #expect(throws: NetworkError.noInternetConnection) {
            try await sut.fetchLocations(page: 1)
        }
    }

    private func makeLocationDTO(id: Int = 1, name: String = "Earth") -> LocationDTO {
        LocationDTO(
            id: id,
            name: name,
            type: "Planet",
            dimension: "Dimension C-137",
            residents: ["https://rickandmortyapi.com/api/character/1"],
            url: "https://rickandmortyapi.com/api/location/\(id)",
            created: "2017-11-10T12:56:33.798Z"
        )
    }
}
