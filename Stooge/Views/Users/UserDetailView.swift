import SwiftUI

struct UserDetailView: View {
    let userId: Int
    @StateObject private var viewModel = UserDetailViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Loading…")
                    .accessibilityIdentifier("user-detail-loading-indicator")

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load(userId: userId) }
                }

            case .loaded:
                if let user = viewModel.user {
                    userContent(user)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load(userId: userId) }
    }

    @ViewBuilder
    private func userContent(_ user: User) -> some View {
        List {
            // Header
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        AvatarView(initial: user.name.prefix(1), size: 72, color: .blue)
                        VStack(spacing: 2) {
                            Text(user.name)
                                .font(.title2.bold())
                                .accessibilityIdentifier("user-name")
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("user-username")
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // Contact
            Section("Contact") {
                LabeledContent("Email", value: user.email)
                    .accessibilityIdentifier("user-email")
                LabeledContent("Phone", value: user.phone)
                    .accessibilityIdentifier("user-phone")
                LabeledContent("Website", value: user.website)
                    .accessibilityIdentifier("user-website")
            }

            // Address
            Section("Address") {
                LabeledContent("Street", value: "\(user.address.street), \(user.address.suite)")
                LabeledContent("City", value: user.address.city)
                LabeledContent("Zip", value: user.address.zipcode)
            }

            // Company
            Section("Company") {
                LabeledContent("Name", value: user.company.name)
                    .accessibilityIdentifier("user-company-name")
                Text(user.company.catchPhrase)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            }

            // Posts
            if !viewModel.posts.isEmpty {
                Section("Posts (\(viewModel.posts.count))") {
                    ForEach(viewModel.posts) { post in
                        NavigationLink(value: post) {
                            Text(post.title.localizedCapitalized)
                                .lineLimit(2)
                        }
                        .accessibilityIdentifier("user-post-row-\(post.id)")
                    }
                }
                .accessibilityIdentifier("user-posts-section")
            }
        }
        .accessibilityIdentifier("user-detail-\(userId)")
        .navigationDestination(for: Post.self) { post in
            PostDetailView(postId: post.id)
        }
    }
}
