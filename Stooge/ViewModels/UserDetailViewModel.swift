import Foundation

@MainActor
final class UserDetailViewModel: ObservableObject {
    @Published var user: User?
    @Published var posts: [Post] = []
    @Published var state: ViewState = .idle

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func load(userId: Int) async {
        guard state != .loading else { return }
        state = .loading
        do {
            async let user = api.fetchUser(id: userId)
            async let posts = api.fetchPosts(byUser: userId)
            let (fetchedUser, fetchedPosts) = try await (user, posts)
            self.user = fetchedUser
            self.posts = fetchedPosts
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
