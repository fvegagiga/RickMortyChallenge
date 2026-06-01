import Foundation
import Network

enum APIEndpoint: Endpoint {
    private static let baseURL = "https://rickandmortyapi.com/api"

    case characters(page: Int, name: String? = nil)
    case characterDetail(id: Int)
    case locations(page: Int)
    case episodes(page: Int)

    var url: URL? {
        guard var components = URLComponents(string: Self.baseURL) else { return nil }

        switch self {
        case .characters(let page, let name):
            components.path += "/character"
            var items = [URLQueryItem(name: "page", value: "\(page)")]
            if let name, !name.isEmpty {
                items.append(URLQueryItem(name: "name", value: name))
            }
            components.queryItems = items

        case .characterDetail(let id):
            components.path += "/character/\(id)"

        case .locations(let page):
            components.path += "/location"
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        case .episodes(let page):
            components.path += "/episode"
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        }

        return components.url
    }
}
