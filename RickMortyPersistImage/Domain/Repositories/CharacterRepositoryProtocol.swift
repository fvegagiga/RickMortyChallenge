import Foundation

protocol CharacterRepositoryProtocol {
    func fetchCharacters(page: Int, name: String?) async throws -> PagedResult<CharacterEntity>
    func fetchCharacterDetail(id: Int) async throws -> CharacterEntity
}
