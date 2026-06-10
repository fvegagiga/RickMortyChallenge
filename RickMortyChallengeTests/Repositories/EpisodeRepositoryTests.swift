import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct EpisodeRepositoryTests {
    let sut: EpisodeRepositoryImpl
    let mockNetworkService: MockNetworkService

    init() {
        mockNetworkService = MockNetworkService()
        sut = EpisodeRepositoryImpl(networkService: mockNetworkService, mapper: EpisodeMapper())
    }

    @Test
    func fetchEpisodes_withValidResponse_returnsMappedEntities() async throws {
        let dto = makeEpisodeDTO(id: 3, name: "Anatomy Park")
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
            results: [dto]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchEpisodes(page: 1)

        #expect(result.items.count == 1)
        #expect(result.items.first?.id == 3)
        #expect(result.items.first?.name == "Anatomy Park")
        #expect(!result.hasNextPage)
    }

    @Test
    func fetchEpisodes_whenNextPageExists_hasNextPageIsTrue() async throws {
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 51, pages: 4, next: "https://rickandmortyapi.com/api/episode?page=2", prev: nil),
            results: [makeEpisodeDTO()]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchEpisodes(page: 1)

        #expect(result.hasNextPage)
        #expect(result.totalCount == 51)
    }

    @Test
    func fetchEpisodes_whenNetworkThrows_propagatesError() async {
        mockNetworkService.errorToThrow = NetworkError.serverError(statusCode: 503)

        await #expect(throws: NetworkError.serverError(statusCode: 503)) {
            try await sut.fetchEpisodes(page: 1)
        }
    }

    private func makeEpisodeDTO(id: Int = 1, name: String = "Pilot") -> EpisodeDTO {
        EpisodeDTO(
            id: id,
            name: name,
            airDate: "December 2, 2013",
            episode: "S01E01",
            characters: ["https://rickandmortyapi.com/api/character/1"],
            url: "https://rickandmortyapi.com/api/episode/\(id)",
            created: "2017-11-10T12:56:33.798Z"
        )
    }
}
