import Combine
import Foundation

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
        self.networkService = networkService
        self.imageCacheManager = imageCacheManager

        self.characterRepository = CharacterRepositoryImpl(
            networkService: networkService,
            mapper: CharacterMapper()
        )
        self.locationRepository = LocationRepositoryImpl(
            networkService: networkService,
            mapper: LocationMapper()
        )
        self.episodeRepository = EpisodeRepositoryImpl(
            networkService: networkService,
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
