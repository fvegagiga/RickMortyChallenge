import Foundation

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationReferenceDTO
    let location: LocationReferenceDTO
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct LocationReferenceDTO: Decodable {
    let name: String
    let url: String
}
