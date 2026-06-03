import Foundation

struct CharacterWidgetData: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let imageFileName: String
    let imageURL: URL?
    let status: String

    init(id: Int, name: String, imageFileName: String, imageURL: URL?, status: String = "") {
        self.id = id
        self.name = name
        self.imageFileName = imageFileName
        self.imageURL = imageURL
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, imageFileName, imageURL, status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageFileName = try container.decode(String.self, forKey: .imageFileName)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
    }
}
