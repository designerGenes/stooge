import SwiftUI

struct AlbumRowView: View {
    let album: Album

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "photo.stack")
                    .foregroundStyle(.purple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(album.title.localizedCapitalized)
                    .font(.subheadline)
                    .lineLimit(2)
                Text("Album #\(album.id)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
