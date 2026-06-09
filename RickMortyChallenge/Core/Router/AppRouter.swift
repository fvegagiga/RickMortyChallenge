import Combine
import SwiftUI

enum CharacterRoute: Hashable {
    case detail(id: Int)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var characterPath = NavigationPath()

    func pushCharacter(_ route: CharacterRoute) {
        characterPath.append(route)
    }
}
