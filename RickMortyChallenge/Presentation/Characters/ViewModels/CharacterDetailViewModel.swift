import Combine
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState<CharacterEntity> = .idle

    private let characterId: Int
    private let getCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol

    init(characterId: Int, getCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol) {
        self.characterId = characterId
        self.getCharacterDetailUseCase = getCharacterDetailUseCase
    }

    func loadDetail() async {
        guard case .idle = viewState else { return }
        viewState = .loading

        do {
            let character = try await getCharacterDetailUseCase.execute(id: characterId)
            viewState = .success(character)
        } catch {
            viewState = .failure(error)
        }
    }

    func retry() async {
        viewState = .idle
        await loadDetail()
    }
}
