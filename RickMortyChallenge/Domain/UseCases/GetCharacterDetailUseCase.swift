import Foundation

protocol GetCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> CharacterEntity
}

final class GetCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> CharacterEntity {
        try await repository.fetchCharacterDetail(id: id)
    }
}
