import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color.DS.portalGreen)
            Text("Loading…")
                .font(.DS.subheadline)
                .foregroundStyle(Color.DS.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
