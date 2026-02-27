import Foundation

@MainActor
final class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var state: ViewState = .idle

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func load() async {
        guard state != .loading else { return }
        state = .loading
        do {
            users = try await api.fetchUsers()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
