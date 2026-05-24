import Foundation
@testable import RickMortyPersistImage

final class MockNetworkService: NetworkServiceProtocol {
    var result: Any?
    var errorToThrow: Error?
    private(set) var lastEndpoint: APIEndpoint?
    private(set) var callCount = 0

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        callCount += 1
        lastEndpoint = endpoint

        if let error = errorToThrow {
            throw error
        }

        guard let value = result as? T else {
            throw NetworkError.decodingFailed("MockNetworkService: result type mismatch")
        }
        return value
    }
}
