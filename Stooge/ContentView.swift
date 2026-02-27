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

            BeneficiaryRootView()
            .tabItem {
                Label("Add Beneficiary", systemImage: "person.badge.plus")
            }
            .accessibilityIdentifier(StoogeA11y.TabBar.beneficiary)
        }
        .accessibilityIdentifier(StoogeA11y.TabBar.root)
    }
}
