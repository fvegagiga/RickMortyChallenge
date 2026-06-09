import SwiftUI

struct EpisodeRowView: View {
    let episode: EpisodeEntity

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            VStack(alignment: .center, spacing: 2) {
                Text(episode.episodeCode)
                    .font(.DS.badge)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, DSSpacing.xxs)
                    .background(Color.DS.portalGreen)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
            }
            .frame(width: 68)

            VStack(alignment: .leading, spacing: 2) {
                Text(episode.name)
                    .font(.DS.headline)
                    .foregroundStyle(Color.DS.textPrimary)
                    .lineLimit(2)

                Text(episode.airDate)
                    .font(.DS.caption)
                    .foregroundStyle(Color.DS.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(episode.characterURLs.count)")
                    .font(.DS.caption)
                    .foregroundStyle(Color.DS.textSecondary)
                Image(systemName: "person.fill")
                    .font(.DS.caption2)
                    .foregroundStyle(Color.DS.textTertiary)
            }
        }
        .padding(.vertical, DSSpacing.xs)
    }
}
