import SwiftUI

struct PostsListView: View {
    @StateObject private var viewModel = PostsViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.posts.isEmpty:
                ProgressView("Loading posts…")
                    .accessibilityIdentifier(StoogeA11y.Posts.loadingIndicator)

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier(StoogeA11y.Posts.errorView)

            default:
                List(viewModel.posts) { post in
                    NavigationLink(value: post) {
                        PostRowView(post: post)
                    }
                    .accessibilityIdentifier(StoogeA11y.Posts.row(post.id))
                }
                .accessibilityIdentifier(StoogeA11y.Posts.list)
                .navigationDestination(for: Post.self) { post in
                    PostDetailView(postId: post.id)
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .navigationTitle("Feed")
        .task { await viewModel.load() }
    }
}
