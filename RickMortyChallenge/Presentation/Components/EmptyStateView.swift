import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    init(
        icon: String = "tray",
        title: String = "No Results",
        subtitle: String = "Try adjusting your search."
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(Color.DS.textTertiary)

            VStack(spacing: DSSpacing.xxs) {
                Text(title)
                    .font(.DS.headline)
                    .foregroundStyle(Color.DS.textPrimary)

                Text(subtitle)
                    .font(.DS.subheadline)
                    .foregroundStyle(Color.DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xl)
    }
}
