import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.DS.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.card, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    func shimmer() -> some View {
        self
            .redacted(reason: .placeholder)
            .shimmering()
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.4),
                        .clear
                    ]),
                    startPoint: .init(x: phase - 0.3, y: 0.5),
                    endPoint: .init(x: phase + 0.3, y: 0.5)
                )
                .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
