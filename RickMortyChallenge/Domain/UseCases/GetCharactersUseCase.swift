import Foundation

protocol GetCharactersUseCaseProtocol {
    func execute(page: Int, name: String?) async throws -> PagedResult<CharacterEntity>
}

final class GetCharactersUseCase: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, name: String?) async throws -> PagedResult<CharacterEntity> {
        try await repository.fetchCharacters(page: page, name: name)
    }
}
