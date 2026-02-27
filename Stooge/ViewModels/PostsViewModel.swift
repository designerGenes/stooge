import Foundation

@MainActor
final class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var state: ViewState = .idle

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func load() async {
        guard state != .loading else { return }
        state = .loading
        do {
            posts = try await api.fetchPosts()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
