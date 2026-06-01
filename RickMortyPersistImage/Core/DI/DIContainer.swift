import Combine
import Foundation
import Network

/// Central dependency container. Created once at app startup and passed via @EnvironmentObject.
/// Factories return new ViewModel instances so each screen owns its own state.
final class DIContainer: ObservableObject {

    // MARK: - Infrastructure

    let networkService: NetworkServiceProtocol
    let imageCacheManager: ImageCacheManagerProtocol

    // MARK: - Repositories (shared; stateless, safe to reuse)

    let characterRepository: CharacterRepositoryProtocol
    let locationRepository: LocationRepositoryProtocol
    let episodeRepository: EpisodeRepositoryProtocol

    // MARK: - Init

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        imageCacheManager: ImageCacheManagerProtocol = ImageCacheManager()
    ) {
        // Wrap with retry logic so all repositories benefit automatically.
        // Tests can inject MockNetworkService directly (no retries) or wrap it too.
        let resilient = RetryingNetworkService(wrapped: networkService)
        self.networkService = resilient
        self.imageCacheManager = imageCacheManager

        self.characterRepository = CharacterRepositoryImpl(
            networkService: resilient,
            mapper: CharacterMapper()
        )
        self.locationRepository = LocationRepositoryImpl(
            networkService: resilient,
            mapper: LocationMapper()
        )
        self.episodeRepository = EpisodeRepositoryImpl(
            networkService: resilient,
            mapper: EpisodeMapper()
        )
    }

    // MARK: - ViewModel Factories

    func makeCharactersListViewModel() -> CharactersListViewModel {
        CharactersListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: characterRepository)
        )
    }

    func makeCharacterDetailViewModel(id: Int) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            characterId: id,
            getCharacterDetailUseCase: GetCharacterDetailUseCase(repository: characterRepository)
        )
    }

    func makeLocationsListViewModel() -> LocationsListViewModel {
        LocationsListViewModel(
            getLocationsUseCase: GetLocationsUseCase(repository: locationRepository)
        )
    }

    func makeEpisodesListViewModel() -> EpisodesListViewModel {
        EpisodesListViewModel(
            getEpisodesUseCase: GetEpisodesUseCase(repository: episodeRepository)
        )
    }
}
