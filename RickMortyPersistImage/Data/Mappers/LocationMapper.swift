import Foundation

struct LocationMapper {
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func map(_ dto: LocationDTO) -> LocationEntity {
        LocationEntity(
            id: dto.id,
            name: dto.name,
            type: dto.type,
            dimension: dto.dimension,
            residentURLs: dto.residents,
            created: Self.iso8601Formatter.date(from: dto.created) ?? .distantPast
        )
    }

    func map(_ dtos: [LocationDTO]) -> [LocationEntity] {
        dtos.map { map($0) }
    }
}
