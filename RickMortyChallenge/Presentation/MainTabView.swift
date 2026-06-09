import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var container: DIContainer
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView {
            CharactersListView(viewModel: container.makeCharactersListViewModel())
                .tabItem {
                    Label("Characters", systemImage: "person.3.fill")
                }
                .tag(0)

            LocationsListView(viewModel: container.makeLocationsListViewModel())
                .tabItem {
                    Label("Locations", systemImage: "globe.americas.fill")
                }
                .tag(1)

            EpisodesListView(viewModel: container.makeEpisodesListViewModel())
                .tabItem {
                    Label("Episodes", systemImage: "film.fill")
                }
                .tag(2)
        }
        .tint(Color.DS.portalGreen)
    }
}
