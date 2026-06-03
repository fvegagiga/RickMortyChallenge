import Foundation

struct CharacterWidgetData: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let imageFileName: String
    let imageURL: URL?
}
