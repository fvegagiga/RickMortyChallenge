import Foundation
import Testing
@testable import RickMortyChallenge

@Suite
struct MapperTests {
    @Test
    func characterMapper_mapsKnownStatusAndGender() {
        let dto = CharacterDTO(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: LocationReferenceDTO(name: "Earth (C-137)", url: ""),
            location: LocationReferenceDTO(name: "Citadel of Ricks", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: ["https://rickandmortyapi.com/api/episode/1"],
            url: "https://rickandmortyapi.com/api/character/1",
            created: "2017-11-04T18:48:46.250Z"
        )

        let entity = CharacterMapper().map(dto)

        #expect(entity.status == .alive)
        #expect(entity.gender == .male)
        #expect(entity.imageURL?.absoluteString == dto.image)
    }

    @Test
    func characterMapper_mapsUnknownStatusAndGenderToUnknown() {
        let dto = CharacterDTO(
            id: 2,
            name: "Unknown",
            status: "Not Real",
            species: "Alien",
            type: "Test",
            gender: "N/A",
            origin: LocationReferenceDTO(name: "Nowhere", url: ""),
            location: LocationReferenceDTO(name: "Nowhere", url: ""),
            image: "",
            episode: [],
            url: "",
            created: "invalid-date"
        )

        let entity = CharacterMapper().map(dto)

        #expect(entity.status == .unknown)
        #expect(entity.gender == .unknown)
        #expect(entity.imageURL == nil)
        #expect(entity.created == .distantPast)
    }

    @Test
    func characterMapper_mapsArray() {
        let dtos = [
            CharacterDTO(
                id: 1, name: "A", status: "Alive", species: "Human", type: "", gender: "Male",
                origin: LocationReferenceDTO(name: "O", url: ""),
                location: LocationReferenceDTO(name: "L", url: ""),
                image: "", episode: [], url: "", created: "2017-11-04T18:48:46.250Z"
            ),
            CharacterDTO(
                id: 2, name: "B", status: "Dead", species: "Human", type: "", gender: "Female",
                origin: LocationReferenceDTO(name: "O", url: ""),
                location: LocationReferenceDTO(name: "L", url: ""),
                image: "", episode: [], url: "", created: "2017-11-04T18:48:46.250Z"
            )
        ]

        let entities = CharacterMapper().map(dtos)

        #expect(entities.count == 2)
        #expect(entities[1].status == .dead)
    }

    @Test
    func episodeMapper_mapsFieldsAndInvalidDate() {
        let dto = EpisodeDTO(
            id: 10,
            name: "Close Rick-Counters",
            airDate: "March 30, 2014",
            episode: "S01E10",
            characters: ["https://rickandmortyapi.com/api/character/1"],
            url: "https://rickandmortyapi.com/api/episode/10",
            created: "2017-11-10T12:56:33.798Z"
        )

        let entity = EpisodeMapper().map(dto)

        #expect(entity.id == 10)
        #expect(entity.episodeCode == "S01E10")
        #expect(entity.characterURLs.count == 1)

        let invalid = EpisodeMapper().map(
            EpisodeDTO(
                id: 11, name: "Bad Date", airDate: "Unknown", episode: "S01E11",
                characters: [], url: "", created: "not-a-date"
            )
        )
        #expect(invalid.created == .distantPast)
    }

    @Test
    func locationMapper_mapsFieldsAndInvalidDate() {
        let dto = LocationDTO(
            id: 20,
            name: "Interdimensional Cable",
            type: "TV",
            dimension: "Unknown",
            residents: ["https://rickandmortyapi.com/api/character/5"],
            url: "https://rickandmortyapi.com/api/location/20",
            created: "2017-11-10T12:56:33.798Z"
        )

        let entity = LocationMapper().map(dto)

        #expect(entity.id == 20)
        #expect(entity.dimension == "Unknown")
        #expect(entity.residentURLs.count == 1)

        let invalid = LocationMapper().map(
            LocationDTO(
                id: 21, name: "Bad Date", type: "Test", dimension: "Test",
                residents: [], url: "", created: "invalid"
            )
        )
        #expect(invalid.created == .distantPast)
    }
}
