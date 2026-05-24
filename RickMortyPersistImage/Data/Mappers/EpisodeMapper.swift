import Foundation

struct EpisodeMapper {
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func map(_ dto: EpisodeDTO) -> EpisodeEntity {
        EpisodeEntity(
            id: dto.id,
            name: dto.name,
            airDate: dto.airDate,
            episodeCode: dto.episode,
            characterURLs: dto.characters,
            created: Self.iso8601Formatter.date(from: dto.created) ?? .distantPast
        )
    }

    func map(_ dtos: [EpisodeDTO]) -> [EpisodeEntity] {
        dtos.map { map($0) }
    }
}
