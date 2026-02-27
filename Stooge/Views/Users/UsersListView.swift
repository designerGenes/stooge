import SwiftUI

struct UsersListView: View {
    @StateObject private var viewModel = UsersViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.users.isEmpty:
                ProgressView("Loading people…")
                    .accessibilityIdentifier("users-loading-indicator")

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier("users-error-view")

            default:
                List(viewModel.users) { user in
                    NavigationLink(value: user) {
                        UserRowView(user: user)
                    }
                    .accessibilityIdentifier("user-row-\(user.id)")
                }
                .accessibilityIdentifier("users-list")
                .navigationDestination(for: User.self) { user in
                    UserDetailView(userId: user.id)
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .navigationTitle("People")
        .task { await viewModel.load() }
    }
}
