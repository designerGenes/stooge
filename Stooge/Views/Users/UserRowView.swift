import SwiftUI

struct UserRowView: View {
    let user: User

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(initial: user.name.prefix(1), size: 44, color: .blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.headline)
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(user.company.name)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
