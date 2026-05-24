import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var characterPath = NavigationPath()
    @Published var locationPath  = NavigationPath()
    @Published var episodePath   = NavigationPath()

    func pushCharacter(_ route: CharacterRoute) {
        characterPath.append(route)
    }

    func pushLocation(_ route: LocationRoute) {
        locationPath.append(route)
    }

    func pushEpisode(_ route: EpisodeRoute) {
        episodePath.append(route)
    }

    func popCharacter() {
        guard !characterPath.isEmpty else { return }
        characterPath.removeLast()
    }

    func popToRootCharacter() {
        characterPath = NavigationPath()
    }

    func popToRootLocation() {
        locationPath = NavigationPath()
    }

    func popToRootEpisode() {
        episodePath = NavigationPath()
    }
}
