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
            .accessibilityIdentifier("tab-feed")

            NavigationStack {
                UsersListView()
            }
            .tabItem {
                Label("People", systemImage: "person.2")
            }
            .accessibilityIdentifier("tab-people")

            NavigationStack {
                AlbumsListView()
            }
            .tabItem {
                Label("Albums", systemImage: "photo.stack")
            }
            .accessibilityIdentifier("tab-albums")
        }
        .accessibilityIdentifier("main-tab-bar")
    }
}
