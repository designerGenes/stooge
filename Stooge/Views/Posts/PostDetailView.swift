import SwiftUI

struct PostDetailView: View {
    let postId: Int
    @StateObject private var viewModel = PostDetailViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Loading…")
                    .accessibilityIdentifier("post-detail-loading-indicator")

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load(postId: postId) }
                }

            case .loaded:
                if let post = viewModel.post {
                    postContent(post)
                }
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load(postId: postId) }
    }

    @ViewBuilder
    private func postContent(_ post: Post) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Body card
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.title.localizedCapitalized)
                        .font(.title2.bold())
                        .accessibilityIdentifier("post-title")

                    if let author = viewModel.author {
                        NavigationLink(value: author) {
                            Label(author.name, systemImage: "person.circle.fill")
                                .font(.subheadline)
                        }
                        .accessibilityIdentifier("post-author-link")
                    }

                    Divider()

                    Text(post.body)
                        .font(.body)
                        .accessibilityIdentifier("post-body")
                }
                .padding()

                // Comments section
                if !viewModel.comments.isEmpty {
                    commentsSection
                }
            }
        }
        .accessibilityIdentifier("post-detail-\(postId)")
        .navigationDestination(for: User.self) { user in
            UserDetailView(userId: user.id)
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Comments")
                .font(.title3.bold())
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

            ForEach(viewModel.comments) { comment in
                CommentRowView(comment: comment)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .accessibilityIdentifier("comment-row-\(comment.id)")
                Divider().padding(.leading)
            }
        }
        .accessibilityIdentifier("comments-list")
    }
}

// MARK: - Comment Row

private struct CommentRowView: View {
    let comment: Comment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "bubble.left")
                    .foregroundStyle(.secondary)
                Text(comment.name.localizedCapitalized)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(comment.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(comment.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
