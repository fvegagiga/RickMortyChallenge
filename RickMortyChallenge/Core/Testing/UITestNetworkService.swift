import Foundation
import Network

/// Deterministic network stub used while UI tests run with the `UI-Testing` launch argument.
final class UITestNetworkService: NetworkServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: some Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        let path = url.path

        if path.contains("/character/"), path != "/api/character" {
            return try decode(T.self, from: Self.characterDetailJSON)
        }

        if path.hasSuffix("/character") {
            return try decode(T.self, from: Self.charactersPageJSON)
        }

        if path.hasSuffix("/location") {
            return try decode(T.self, from: Self.locationsPageJSON)
        }

        if path.hasSuffix("/episode") {
            return try decode(T.self, from: Self.episodesPageJSON)
        }

        throw NetworkError.unknown("UITestNetworkService: unhandled endpoint \(path)")
    }

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        guard let data = json.data(using: .utf8) else {
            throw NetworkError.decodingFailed("UITestNetworkService: invalid UTF-8 fixture")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    private static let charactersPageJSON = """
    {
      "info": { "count": 2, "pages": 1, "next": null, "prev": null },
      "results": [
        {
          "id": 1,
          "name": "Rick Sanchez",
          "status": "Alive",
          "species": "Human",
          "type": "",
          "gender": "Male",
          "origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
          "location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
          "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
          "episode": ["https://rickandmortyapi.com/api/episode/1"],
          "url": "https://rickandmortyapi.com/api/character/1",
          "created": "2017-11-04T18:48:46.250Z"
        },
        {
          "id": 2,
          "name": "Morty Smith",
          "status": "Alive",
          "species": "Human",
          "type": "",
          "gender": "Male",
          "origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
          "location": { "name": "Earth (Replacement Dimension)", "url": "https://rickandmortyapi.com/api/location/20" },
          "image": "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
          "episode": ["https://rickandmortyapi.com/api/episode/1"],
          "url": "https://rickandmortyapi.com/api/character/2",
          "created": "2017-11-04T18:50:21.651Z"
        }
      ]
    }
    """

    private static let characterDetailJSON = """
    {
      "id": 1,
      "name": "Rick Sanchez",
      "status": "Alive",
      "species": "Human",
      "type": "",
      "gender": "Male",
      "origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
      "location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
      "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
      "episode": ["https://rickandmortyapi.com/api/episode/1"],
      "url": "https://rickandmortyapi.com/api/character/1",
      "created": "2017-11-04T18:48:46.250Z"
    }
    """

    private static let locationsPageJSON = """
    {
      "info": { "count": 2, "pages": 1, "next": null, "prev": null },
      "results": [
        {
          "id": 1,
          "name": "Earth (C-137)",
          "type": "Planet",
          "dimension": "Dimension C-137",
          "residents": ["https://rickandmortyapi.com/api/character/1"],
          "url": "https://rickandmortyapi.com/api/location/1",
          "created": "2017-11-10T12:42:04.162Z"
        },
        {
          "id": 2,
          "name": "Abadango",
          "type": "Cluster",
          "dimension": "Unknown",
          "residents": ["https://rickandmortyapi.com/api/character/6"],
          "url": "https://rickandmortyapi.com/api/location/2",
          "created": "2017-11-10T12:42:04.162Z"
        }
      ]
    }
    """

    private static let episodesPageJSON = """
    {
      "info": { "count": 2, "pages": 1, "next": null, "prev": null },
      "results": [
        {
          "id": 1,
          "name": "Pilot",
          "air_date": "December 2, 2013",
          "episode": "S01E01",
          "characters": ["https://rickandmortyapi.com/api/character/1"],
          "url": "https://rickandmortyapi.com/api/episode/1",
          "created": "2017-11-10T12:56:33.798Z"
        },
        {
          "id": 2,
          "name": "Lawnmower Dog",
          "air_date": "December 9, 2013",
          "episode": "S01E02",
          "characters": ["https://rickandmortyapi.com/api/character/1"],
          "url": "https://rickandmortyapi.com/api/episode/2",
          "created": "2017-11-10T12:56:33.798Z"
        }
      ]
    }
    """
}

enum UITestLaunchConfiguration {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("UI-Testing")
    }
}
