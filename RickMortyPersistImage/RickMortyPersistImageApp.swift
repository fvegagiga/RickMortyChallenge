import SwiftUI

@main
struct RickMortyPersistImageApp: App {
    @StateObject private var container = DIContainer()
    @StateObject private var router    = AppRouter()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(container)
                .environmentObject(router)
        }
    }
}
