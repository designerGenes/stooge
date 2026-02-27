import Foundation

@MainActor
final class AlbumsViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var state: ViewState = .idle

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func load() async {
        guard state != .loading else { return }
        state = .loading
        do {
            albums = try await api.fetchAlbums()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
