import SwiftUI

struct AlbumsListView: View {
    @StateObject private var viewModel = AlbumsViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.albums.isEmpty:
                ProgressView("Loading albums…")
                    .accessibilityIdentifier("albums-loading-indicator")

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier("albums-error-view")

            default:
                List(viewModel.albums) { album in
                    NavigationLink(value: album) {
                        AlbumRowView(album: album)
                    }
                    .accessibilityIdentifier("album-row-\(album.id)")
                }
                .accessibilityIdentifier("albums-list")
                .navigationDestination(for: Album.self) { album in
                    AlbumDetailView(albumId: album.id)
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .navigationTitle("Albums")
        .task { await viewModel.load() }
    }
}
