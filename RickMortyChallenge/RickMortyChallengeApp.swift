import SwiftUI

@main
struct RickMortyChallengeApp: App {
    @StateObject private var container = RickMortyChallengeApp.makeContainer()
    @StateObject private var router    = AppRouter()

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["DISABLE_APP_BOOTSTRAP_FOR_SCREENSHOT_TESTS"] == "1" {
                Color.clear
            } else {
                MainTabView()
                    .environmentObject(container)
                    .environmentObject(router)
            }
        }
    }

    private static func makeContainer() -> DIContainer {
        if UITestLaunchConfiguration.isEnabled {
            return DIContainer(networkService: UITestNetworkService())
        }
        return DIContainer()
    }
}
