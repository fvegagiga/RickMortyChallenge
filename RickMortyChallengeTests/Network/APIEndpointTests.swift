import Foundation
import Testing
@testable import RickMortyChallenge

@Suite
struct APIEndpointTests {
    @Test
    func charactersURL_includesPageAndOptionalName() throws {
        let endpoint = APIEndpoint.characters(page: 2, name: "Rick")
        let url = try #require(endpoint.url)
        let query = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.query)

        #expect(url.path.hasSuffix("/character"))
        #expect(query.contains("page=2"))
        #expect(query.contains("name=Rick"))
    }

    @Test
    func charactersURL_omitsNameWhenEmpty() throws {
        let endpoint = APIEndpoint.characters(page: 1, name: "")
        let url = try #require(endpoint.url)
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.query ?? ""

        #expect(!query.contains("name="))
    }

    @Test
    func characterDetailURL_includesId() throws {
        let endpoint = APIEndpoint.characterDetail(id: 42)
        let url = try #require(endpoint.url)

        #expect(url.path.hasSuffix("/character/42"))
    }

    @Test
    func locationsURL_includesPage() throws {
        let endpoint = APIEndpoint.locations(page: 5)
        let url = try #require(endpoint.url)
        let query = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.query)

        #expect(url.path.hasSuffix("/location"))
        #expect(query.contains("page=5"))
    }

    @Test
    func episodesURL_includesPage() throws {
        let endpoint = APIEndpoint.episodes(page: 3)
        let url = try #require(endpoint.url)
        let query = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.query)

        #expect(url.path.hasSuffix("/episode"))
        #expect(query.contains("page=3"))
    }
}
