import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PostsListView()
            }
            .tabItem {
                Label("Feed", systemImage: "newspaper")
            }
            .accessibilityIdentifier(StoogeA11y.TabBar.feed)

            NavigationStack {
                UsersListView()
            }
            .tabItem {
                Label("People", systemImage: "person.2")
            }
            .accessibilityIdentifier(StoogeA11y.TabBar.people)

            NavigationStack {
                AlbumsListView()
            }
            .tabItem {
                Label("Albums", systemImage: "photo.stack")
            }
            .accessibilityIdentifier(StoogeA11y.TabBar.albums)
        }
        .accessibilityIdentifier(StoogeA11y.TabBar.root)
    }
}
