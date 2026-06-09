import Foundation

struct CharacterEntity: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: CharacterGender
    let originName: String
    let currentLocationName: String
    let imageURL: URL?
    let episodeURLs: [String]
    let created: Date
}

enum CharacterStatus: String, Hashable, Sendable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .alive:   return "Alive"
        case .dead:    return "Dead"
        case .unknown: return "Unknown"
        }
    }
}

enum CharacterGender: String, Hashable, Sendable {
    case female     = "Female"
    case male       = "Male"
    case genderless = "Genderless"
    case unknown    = "unknown"

    var displayName: String {
        switch self {
        case .female:     return "Female"
        case .male:       return "Male"
        case .genderless: return "Genderless"
        case .unknown:    return "Unknown"
        }
    }
}
