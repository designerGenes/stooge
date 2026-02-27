import SwiftUI

struct PostRowView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(post.title.localizedCapitalized)
                .font(.headline)
                .lineLimit(2)

            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Label("User \(post.userId)", systemImage: "person.circle")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
