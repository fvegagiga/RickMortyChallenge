import Network
import Testing
@testable import RickMortyChallenge

@Suite @MainActor
struct CharacterRepositoryTests {
    let sut: CharacterRepositoryImpl
    let mockNetworkService: MockNetworkService
    let mapper = CharacterMapper()

    init() {
        mockNetworkService = MockNetworkService()
        sut = CharacterRepositoryImpl(networkService: mockNetworkService, mapper: mapper)
    }

    @Test
    func fetchCharacters_withValidResponse_returnsMappedEntities() async throws {
        let dto = makeCharacterDTO(id: 7, name: "Rick Sanchez")
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
            results: [dto]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchCharacters(page: 1, name: nil)

        #expect(result.items.count == 1)
        #expect(result.items.first?.id == 7)
        #expect(result.items.first?.name == "Rick Sanchez")
        #expect(!result.hasNextPage)
    }

    @Test
    func fetchCharacters_whenNextPageExists_hasNextPageIsTrue() async throws {
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 826, pages: 42, next: "https://rickandmortyapi.com/api/character?page=2", prev: nil),
            results: [makeCharacterDTO()]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchCharacters(page: 1, name: nil)

        #expect(result.hasNextPage)
    }

    @Test
    func fetchCharacters_whenNetworkThrows_propagatesError() async {
        mockNetworkService.errorToThrow = NetworkError.noInternetConnection

        await #expect(throws: NetworkError.noInternetConnection) {
            try await sut.fetchCharacters(page: 1, name: nil)
        }
    }

    @Test
    func fetchCharacterDetail_withValidDTO_returnsMappedEntity() async throws {
        let dto = makeCharacterDTO(id: 42, name: "Morty Smith")
        mockNetworkService.result = dto

        let entity = try await sut.fetchCharacterDetail(id: 42)

        #expect(entity.id == 42)
        #expect(entity.name == "Morty Smith")
    }

    private func makeCharacterDTO(id: Int = 1, name: String = "Rick") -> CharacterDTO {
        CharacterDTO(
            id: id,
            name: name,
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: LocationReferenceDTO(name: "Earth (C-137)", url: ""),
            location: LocationReferenceDTO(name: "Citadel of Ricks", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg",
            episode: ["https://rickandmortyapi.com/api/episode/1"],
            url: "https://rickandmortyapi.com/api/character/\(id)",
            created: "2017-11-04T18:48:46.250Z"
        )
    }
}
