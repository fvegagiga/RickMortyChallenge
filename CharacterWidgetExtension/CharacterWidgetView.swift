import SwiftUI
import WidgetKit
import AppIntents

struct CharacterWidgetView: View {
    let entry: CharacterWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallLayout
        case .systemMedium:
            wideLayout
        default:
            smallLayout
        }
    }

    // MARK: - Status color

    private var statusColor: Color {
        switch entry.character?.status {
        case "Alive":   return Color.DS.statusAlive
        case "Dead":    return Color.DS.statusDead
        default:        return Color.DS.statusUnknown
        }
    }

    // MARK: - systemSmall

    private var smallLayout: some View {
        ZStack(alignment: .bottom) {
            characterImage
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                nameLabel
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, DSSpacing.xxs)
                    .frame(maxWidth: .infinity)

                navigationBar
            }
        }
        .containerBackground(.background, for: .widget)
    }

    // MARK: - Wide (1x2)

    private var wideLayout: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                characterImage
                    .frame(width: 118)
                    .frame(maxHeight: .infinity)
                    .clipped()

                wideInfoPanel
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            wideNavigationBar
                .padding(.bottom, DSSpacing.xs)
                .padding(.top, DSSpacing.xxs)
        }
        .containerBackground(.background, for: .widget)
    }

    // MARK: - Subviews

    private var characterImage: some View {
        Group {
            if let character = entry.character,
               let url = AppGroupStore().imageURL(for: character.id),
               let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if entry.character != nil {
                Rectangle()
                    .fill(Color.DS.cardBackground)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    )
            } else {
                Rectangle()
                    .fill(Color.DS.cardBackground)
                    .overlay(
                        VStack(spacing: DSSpacing.xs) {
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("Open the app to load characters")
                                .font(Font.DS.caption2)
                                .foregroundStyle(Color.DS.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DSSpacing.xs)
                        }
                    )
            }
        }
    }

    private var nameLabel: some View {
        HStack(spacing: DSSpacing.xxs) {
            if entry.character != nil {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }
            Text(entry.character?.name ?? "–")
                .font(Font.DS.caption)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
    }

    private var wideInfoPanel: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            if entry.character != nil {
                HStack(spacing: DSSpacing.xxs) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(entry.character?.status ?? "Unknown")
                        .font(Font.DS.caption2)
                        .foregroundStyle(Color.DS.textSecondary)
                }
            }

            Text(entry.character?.name ?? "Open the app to load characters")
                .font(Font.DS.caption)
                .foregroundStyle(Color.DS.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)

            Spacer(minLength: 0)

            if entry.totalCount > 0 {
                Text("\(entry.currentIndex + 1) / \(entry.totalCount)")
                    .font(Font.DS.caption2)
                    .foregroundStyle(Color.DS.textSecondary)
            }
        }
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.sm)
        .padding(.leading, DSSpacing.xs)
        .padding(.trailing, DSSpacing.sm)
    }

    private var navigationBar: some View {
        HStack {
            Button(intent: PreviousCharacterIntent()) {
                Image(systemName: "chevron.left")
                    .font(Font.DS.caption)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.DS.portalGreen)

            Spacer()

            if entry.totalCount > 0 {
                Text("\(entry.currentIndex + 1) / \(entry.totalCount)")
                    .font(Font.DS.caption2)
                    .foregroundStyle(Color.DS.textSecondary)
            }

            Spacer()

            Button(intent: NextCharacterIntent()) {
                Image(systemName: "chevron.right")
                    .font(Font.DS.caption)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.DS.portalGreen)
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, DSSpacing.xxs)
    }

    private var wideNavigationBar: some View {
        HStack {
            Button(intent: PreviousCharacterIntent()) {
                Image(systemName: "chevron.left")
                    .font(Font.DS.caption)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.DS.portalGreen)

            Spacer()

            Button(intent: NextCharacterIntent()) {
                Image(systemName: "chevron.right")
                    .font(Font.DS.caption)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.DS.portalGreen)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#Preview("Small — loaded", as: .systemSmall) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(
        date: .now,
        character: CharacterWidgetData(id: 1, name: "Rick Sanchez", imageFileName: "1.jpg", imageURL: nil, status: "Alive"),
        currentIndex: 0,
        totalCount: 5
    )
}

#Preview("Medium — loaded", as: .systemMedium) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(
        date: .now,
        character: CharacterWidgetData(id: 1, name: "Rick Sanchez", imageFileName: "1.jpg", imageURL: nil, status: "Alive"),
        currentIndex: 0,
        totalCount: 5
    )
}

#Preview("Small — placeholder", as: .systemSmall) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(date: .now, character: nil, currentIndex: 0, totalCount: 0)
}

#Preview("Medium — placeholder", as: .systemMedium) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(date: .now, character: nil, currentIndex: 0, totalCount: 0)
}
