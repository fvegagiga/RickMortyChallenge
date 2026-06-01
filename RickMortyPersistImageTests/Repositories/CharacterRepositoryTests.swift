import XCTest
import Network
@testable import RickMortyPersistImage

@MainActor
final class CharacterRepositoryTests: XCTestCase {
    var sut: CharacterRepositoryImpl!
    var mockNetworkService: MockNetworkService!
    let mapper = CharacterMapper()

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = CharacterRepositoryImpl(networkService: mockNetworkService, mapper: mapper)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func testFetchCharacters_withValidResponse_returnsMappedEntities() async throws {
        let dto = makeCharacterDTO(id: 7, name: "Rick Sanchez")
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
            results: [dto]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchCharacters(page: 1, name: nil)

        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.id, 7)
        XCTAssertEqual(result.items.first?.name, "Rick Sanchez")
        XCTAssertFalse(result.hasNextPage)
    }

    func testFetchCharacters_whenNextPageExists_hasNextPageIsTrue() async throws {
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 826, pages: 42, next: "https://rickandmortyapi.com/api/character?page=2", prev: nil),
            results: [makeCharacterDTO()]
        )
        mockNetworkService.result = response

        let result = try await sut.fetchCharacters(page: 1, name: nil)

        XCTAssertTrue(result.hasNextPage)
    }

    func testFetchCharacters_whenNetworkThrows_propagatesError() async {
        mockNetworkService.errorToThrow = NetworkError.noInternetConnection

        do {
            _ = try await sut.fetchCharacters(page: 1, name: nil)
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noInternetConnection)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchCharacterDetail_withValidDTO_returnsMappedEntity() async throws {
        let dto = makeCharacterDTO(id: 42, name: "Morty Smith")
        mockNetworkService.result = dto

        let entity = try await sut.fetchCharacterDetail(id: 42)

        XCTAssertEqual(entity.id, 42)
        XCTAssertEqual(entity.name, "Morty Smith")
    }

    // MARK: - Helpers

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
