import SwiftUI

struct CharacterCardView: View {
    let character: CharacterEntity
    let cacheManager: ImageCacheManagerProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CachedAsyncImageView(
                url: character.imageURL,
                cacheManager: cacheManager
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.DS.cardBackground)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.DS.textTertiary)
                    }
            }
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(character.name)
                    .font(.DS.headline)
                    .foregroundStyle(Color.DS.textPrimary)
                    .lineLimit(1)

                StatusBadgeView(status: character.status)

                Text(character.species)
                    .font(.DS.caption)
                    .foregroundStyle(Color.DS.textSecondary)
                    .lineLimit(1)
            }
            .padding(DSSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.DS.cardBackground)
        }
        .cardStyle()
    }
}
