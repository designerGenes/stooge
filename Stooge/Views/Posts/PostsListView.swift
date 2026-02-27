import SwiftUI

struct PostsListView: View {
    @StateObject private var viewModel = PostsViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.posts.isEmpty:
                ProgressView("Loading posts…")
                    .accessibilityIdentifier("posts-loading-indicator")

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier("posts-error-view")

            default:
                List(viewModel.posts) { post in
                    NavigationLink(value: post) {
                        PostRowView(post: post)
                    }
                    .accessibilityIdentifier("post-row-\(post.id)")
                }
                .accessibilityIdentifier("posts-list")
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
