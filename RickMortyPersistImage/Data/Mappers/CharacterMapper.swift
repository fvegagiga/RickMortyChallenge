import Foundation

struct CharacterMapper {
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func map(_ dto: CharacterDTO) -> CharacterEntity {
        CharacterEntity(
            id: dto.id,
            name: dto.name,
            status: CharacterStatus(rawValue: dto.status) ?? .unknown,
            species: dto.species,
            type: dto.type,
            gender: CharacterGender(rawValue: dto.gender) ?? .unknown,
            originName: dto.origin.name,
            currentLocationName: dto.location.name,
            imageURL: URL(string: dto.image),
            episodeURLs: dto.episode,
            created: Self.iso8601Formatter.date(from: dto.created) ?? .distantPast
        )
    }

    func map(_ dtos: [CharacterDTO]) -> [CharacterEntity] {
        dtos.map { map($0) }
    }
}
