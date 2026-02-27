import SwiftUI

struct AlbumsListView: View {
    @StateObject private var viewModel = AlbumsViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.albums.isEmpty:
                ProgressView("Loading albums…")
                    .accessibilityIdentifier(StoogeA11y.Albums.loadingIndicator)

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load() }
                }
                .accessibilityIdentifier(StoogeA11y.Albums.errorView)

            default:
                List(viewModel.albums) { album in
                    NavigationLink(value: album) {
                        AlbumRowView(album: album)
                    }
                    .accessibilityIdentifier(StoogeA11y.Albums.row(album.id))
                }
                .accessibilityIdentifier(StoogeA11y.Albums.list)
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
