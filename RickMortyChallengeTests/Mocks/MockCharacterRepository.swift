import Foundation
@testable import RickMortyChallenge

final class MockCharacterRepository: CharacterRepositoryProtocol {
    var fetchCharactersResult: Result<PagedResult<CharacterEntity>, Error> = .success(
        MockDataFactory.makePagedResult(items: [])
    )
    private(set) var fetchCharactersCallCount = 0
    private(set) var lastFetchPage: Int?
    private(set) var lastFetchName: String?

    func fetchCharacters(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        fetchCharactersCallCount += 1
        lastFetchPage = page
        lastFetchName = name
        return try fetchCharactersResult.get()
    }

    var fetchCharacterDetailResult: Result<CharacterEntity, Error> = .success(
        MockDataFactory.makeCharacterEntity()
    )
    private(set) var fetchDetailCallCount = 0
    private(set) var lastDetailId: Int?

    func fetchCharacterDetail(id: Int) async throws -> CharacterEntity {
        fetchDetailCallCount += 1
        lastDetailId = id
        return try fetchCharacterDetailResult.get()
    }
}
