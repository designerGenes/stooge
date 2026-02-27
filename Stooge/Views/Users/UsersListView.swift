import SwiftUI

struct UsersListView: View {
    @StateObject private var viewModel = UsersViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.users.isEmpty:
                ProgressView("Loading people…")
                    .accessibilityIdentifier(StoogeA11y.Users.loadingIndicator)

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier(StoogeA11y.Users.errorView)

            default:
                List(viewModel.users) { user in
                    NavigationLink(value: user) {
                        UserRowView(user: user)
                    }
                    .accessibilityIdentifier(StoogeA11y.Users.row(user.id))
                }
                .accessibilityIdentifier(StoogeA11y.Users.list)
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
