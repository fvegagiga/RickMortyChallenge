import SwiftUI

struct LocationRowView: View {
    let location: LocationEntity

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: iconName(for: location.type))
                .foregroundStyle(Color.DS.portalGreen)
                .frame(width: 36, height: 36)
                .background(Color.DS.portalGreen.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.DS.headline)
                    .foregroundStyle(Color.DS.textPrimary)
                    .lineLimit(1)

                HStack(spacing: DSSpacing.xxs) {
                    if !location.type.isEmpty {
                        Text(location.type)
                            .font(.DS.caption)
                            .foregroundStyle(Color.DS.textSecondary)
                    }
                    if !location.dimension.isEmpty && location.dimension != "unknown" {
                        Text("·")
                            .font(.DS.caption)
                            .foregroundStyle(Color.DS.textTertiary)
                        Text(location.dimension)
                            .font(.DS.caption)
                            .foregroundStyle(Color.DS.textTertiary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Text("\(location.residentURLs.count)")
                .font(.DS.caption2)
                .foregroundStyle(Color.DS.textSecondary)
            Image(systemName: "person.2.fill")
                .font(.DS.caption2)
                .foregroundStyle(Color.DS.textTertiary)
        }
        .padding(.vertical, DSSpacing.xs)
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "planet":       return "globe.americas.fill"
        case "space station": return "antenna.radiowaves.left.and.right"
        case "microverse":   return "atom"
        case "cluster":      return "star.fill"
        case "dream":        return "moon.zzz.fill"
        case "fantasy town": return "house.fill"
        default:             return "mappin.circle.fill"
        }
    }
}
