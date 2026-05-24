import SwiftUI

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.DS.statusDead)

            VStack(spacing: DSSpacing.xs) {
                Text("Something went wrong")
                    .font(.DS.headline)
                    .foregroundStyle(Color.DS.textPrimary)

                Text(error.localizedDescription)
                    .font(.DS.caption)
                    .foregroundStyle(Color.DS.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.lg)
            }

            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.DS.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.xl)
                    .padding(.vertical, DSSpacing.sm)
                    .background(Color.DS.portalGreen)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xl)
    }
}
