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
            mediumLayout
        default:
            smallLayout
        }
    }

    // MARK: - systemSmall

    private var smallLayout: some View {
        ZStack(alignment: .bottom) {
            characterImage
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                nameLabel
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)

                navigationBar
                    .background(.ultraThinMaterial)
            }
        }
        .containerBackground(.background, for: .widget)
    }

    // MARK: - systemMedium

    private var mediumLayout: some View {
        HStack(spacing: 0) {
            characterImage
                .frame(maxWidth: .infinity)
                .clipped()

            VStack(alignment: .leading, spacing: 12) {
                Spacer()
                nameLabel
                    .lineLimit(2)
                Spacer()
                navigationBar
            }
            .padding(12)
            .frame(maxWidth: .infinity)
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
            } else {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    )
            }
        }
    }

    private var nameLabel: some View {
        Text(entry.character?.name ?? "–")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }

    private var navigationBar: some View {
        HStack {
            Button(intent: PreviousCharacterIntent()) {
                Image(systemName: "chevron.left")
                    .font(.caption.weight(.bold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(intent: NextCharacterIntent()) {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("Small — loaded", as: .systemSmall) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(
        date: .now,
        character: CharacterWidgetData(id: 1, name: "Rick Sanchez", imageFileName: "1.jpg", imageURL: nil)
    )
}

#Preview("Medium — loaded", as: .systemMedium) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(
        date: .now,
        character: CharacterWidgetData(id: 1, name: "Rick Sanchez", imageFileName: "1.jpg", imageURL: nil)
    )
}

#Preview("Small — placeholder", as: .systemSmall) {
    CharacterWidget()
} timeline: {
    CharacterWidgetEntry(date: .now, character: nil)
}
