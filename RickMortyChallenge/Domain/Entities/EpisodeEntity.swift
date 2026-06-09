import Foundation

struct EpisodeEntity: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let airDate: String
    let episodeCode: String
    let characterURLs: [String]
    let created: Date

    var seasonNumber: String? {
        guard episodeCode.count >= 3 else { return nil }
        return String(episodeCode.prefix(3))
    }
}
