import SwiftUI

struct AvatarView<S: StringProtocol>: View {
    let initial: S
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: size, height: size)
            Text(initial)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}
