import Foundation

struct LocationEntity: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residentURLs: [String]
    let created: Date
}
