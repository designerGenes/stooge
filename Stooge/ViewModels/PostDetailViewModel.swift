import Foundation

@MainActor
final class PostDetailViewModel: ObservableObject {
    @Published var post: Post?
    @Published var author: User?
    @Published var comments: [Comment] = []
    @Published var state: ViewState = .idle

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func load(postId: Int) async {
        guard state != .loading else { return }
        state = .loading
        do {
            async let post = api.fetchPost(id: postId)
            async let comments = api.fetchComments(forPost: postId)
            let (fetchedPost, fetchedComments) = try await (post, comments)
            self.post = fetchedPost
            self.comments = fetchedComments
            self.author = try await api.fetchUser(id: fetchedPost.userId)
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
