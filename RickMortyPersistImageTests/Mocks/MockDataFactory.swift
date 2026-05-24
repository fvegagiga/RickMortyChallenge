import Foundation
@testable import RickMortyPersistImage

enum MockDataFactory {

    static func makeCharacterEntity(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: CharacterStatus = .alive,
        species: String = "Human"
    ) -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: name,
            status: status,
            species: species,
            type: "",
            gender: .male,
            originName: "Earth (C-137)",
            currentLocationName: "Citadel of Ricks",
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
            episodeURLs: ["https://rickandmortyapi.com/api/episode/1"],
            created: Date()
        )
    }

    static func makeCharacterEntities(count: Int) -> [CharacterEntity] {
        (1...count).map { i in
            makeCharacterEntity(id: i, name: "Character \(i)")
        }
    }

    static func makeLocationEntity(
        id: Int = 1,
        name: String = "Earth (C-137)"
    ) -> LocationEntity {
        LocationEntity(
            id: id,
            name: name,
            type: "Planet",
            dimension: "Dimension C-137",
            residentURLs: ["https://rickandmortyapi.com/api/character/1"],
            created: Date()
        )
    }

    static func makeLocationEntities(count: Int) -> [LocationEntity] {
        (1...count).map { i in makeLocationEntity(id: i, name: "Location \(i)") }
    }

    static func makeEpisodeEntity(
        id: Int = 1,
        name: String = "Pilot"
    ) -> EpisodeEntity {
        EpisodeEntity(
            id: id,
            name: name,
            airDate: "December 2, 2013",
            episodeCode: "S01E01",
            characterURLs: ["https://rickandmortyapi.com/api/character/1"],
            created: Date()
        )
    }

    static func makeEpisodeEntities(count: Int) -> [EpisodeEntity] {
        (1...count).map { i in makeEpisodeEntity(id: i, name: "Episode \(i)") }
    }

    static func makePagedResult<T: Sendable>(
        items: [T],
        hasNextPage: Bool = false
    ) -> PagedResult<T> {
        PagedResult(items: items, hasNextPage: hasNextPage, totalCount: items.count)
    }
}
