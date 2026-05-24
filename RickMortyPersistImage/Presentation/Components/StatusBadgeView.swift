import SwiftUI

struct StatusBadgeView: View {
    let status: CharacterStatus

    private var color: Color {
        switch status {
        case .alive:   return Color.DS.statusAlive
        case .dead:    return Color.DS.statusDead
        case .unknown: return Color.DS.statusUnknown
        }
    }

    var body: some View {
        HStack(spacing: DSSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(status.displayName)
                .font(.DS.badge)
                .foregroundStyle(color)
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}
