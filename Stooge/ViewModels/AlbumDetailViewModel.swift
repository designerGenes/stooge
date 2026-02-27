import Foundation

@MainActor
final class AlbumDetailViewModel: ObservableObject {
    @Published var album: Album?
    @Published var photos: [Photo] = []
    @Published var state: ViewState = .idle

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func load(albumId: Int) async {
        guard state != .loading else { return }
        state = .loading
        do {
            async let album = api.fetchAlbum(id: albumId)
            async let photos = api.fetchPhotos(forAlbum: albumId)
            let (fetchedAlbum, fetchedPhotos) = try await (album, photos)
            self.album = fetchedAlbum
            self.photos = fetchedPhotos
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
