import SwiftUI

struct AlbumDetailView: View {
    let albumId: Int
    @StateObject private var viewModel = AlbumDetailViewModel()

    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 8)]

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Loading photos…")
                    .accessibilityIdentifier(StoogeA11y.Albums.Detail.loadingIndicator)

            case .failed:
                ErrorView(message: viewModel.state.errorMessage ?? "Something went wrong") {
                    Task { await viewModel.load(albumId: albumId) }
                }

            case .loaded:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(viewModel.photos) { photo in
                            PhotoTileView(photo: photo)
                                .accessibilityIdentifier(StoogeA11y.Albums.Detail.photoTile(photo.id))
                        }
                    }
                    .padding()
                }
                .accessibilityIdentifier(StoogeA11y.Albums.Detail.photosGrid(albumId))
            }
        }
        .navigationTitle(viewModel.album?.title.localizedCapitalized ?? "Album")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load(albumId: albumId) }
    }
}

// MARK: - Photo Tile

private struct PhotoTileView: View {
    let photo: Photo

    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: photo.thumbnailUrl)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.15))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.15))
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)

            Text(photo.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
}
