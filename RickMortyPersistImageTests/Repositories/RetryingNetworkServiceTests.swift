import XCTest
@testable import RickMortyPersistImage

final class RetryingNetworkServiceTests: XCTestCase {
    var mockInner: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockInner = MockNetworkService()
    }

    override func tearDown() {
        mockInner = nil
        super.tearDown()
    }

    // MARK: - Happy path

    func testFetch_whenNoError_returnsResultOnFirstAttempt() async throws {
        let expected = MockDataFactory.makeCharacterEntities(count: 2)
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 2, pages: 1, next: nil, prev: nil),
            results: expected.map { makeCharacterDTO(id: $0.id) }
        )
        mockInner.result = response

        let sut = RetryingNetworkService(wrapped: mockInner, maxRetries: 3, baseDelay: 0.0)
        let _: PaginatedResponseDTO<CharacterDTO> = try await sut.fetch(.characters(page: 1))

        XCTAssertEqual(mockInner.callCount, 1)
    }

    // MARK: - Retry on 429

    func testFetch_on429_retriesAndEventuallySucceeds() async throws {
        let response = PaginatedResponseDTO(
            info: PaginationInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
            results: [makeCharacterDTO(id: 1)]
        )
        mockInner.result = response
        mockInner.errorToThrow = NetworkError.rateLimited(retryAfter: 0.0)
        mockInner.failCount = 2  // fail twice, succeed on 3rd call

        let sut = RetryingNetworkService(wrapped: mockInner, maxRetries: 3, baseDelay: 0.0)
        let _: PaginatedResponseDTO<CharacterDTO> = try await sut.fetch(.characters(page: 1))

        XCTAssertEqual(mockInner.callCount, 3, "Should have made 3 attempts (2 failures + 1 success)")
    }

    func testFetch_on429_whenRetriesExhausted_throwsRateLimited() async {
        mockInner.errorToThrow = NetworkError.rateLimited(retryAfter: 0.0)
        mockInner.failCount = .max  // always fail

        let sut = RetryingNetworkService(wrapped: mockInner, maxRetries: 2, baseDelay: 0.0)

        do {
            let _: PaginatedResponseDTO<CharacterDTO> = try await sut.fetch(.characters(page: 1))
            XCTFail("Should have thrown")
        } catch let error as NetworkError {
            guard case .rateLimited = error else {
                return XCTFail("Expected .rateLimited, got \(error)")
            }
            XCTAssertEqual(mockInner.callCount, 3, "maxRetries=2 → 3 total attempts")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Non-429 errors are NOT retried

    func testFetch_onNotFound_doesNotRetry() async {
        mockInner.errorToThrow = NetworkError.notFound
        mockInner.failCount = .max

        let sut = RetryingNetworkService(wrapped: mockInner, maxRetries: 3, baseDelay: 0.0)

        do {
            let _: PaginatedResponseDTO<CharacterDTO> = try await sut.fetch(.characters(page: 1))
            XCTFail("Should have thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .notFound)
            XCTAssertEqual(mockInner.callCount, 1, "Not-found errors must not be retried")
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func testFetch_onServerError_doesNotRetry() async {
        mockInner.errorToThrow = NetworkError.serverError(statusCode: 500)
        mockInner.failCount = .max

        let sut = RetryingNetworkService(wrapped: mockInner, maxRetries: 3, baseDelay: 0.0)

        do {
            let _: PaginatedResponseDTO<CharacterDTO> = try await sut.fetch(.characters(page: 1))
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(mockInner.callCount, 1, "5xx errors must not be retried")
        }
    }

    // MARK: - Helpers

    private func makeCharacterDTO(id: Int) -> CharacterDTO {
        CharacterDTO(
            id: id, name: "Rick \(id)", status: "Alive", species: "Human",
            type: "", gender: "Male",
            origin: LocationReferenceDTO(name: "Earth", url: ""),
            location: LocationReferenceDTO(name: "Earth", url: ""),
            image: "", episode: [], url: "", created: "2017-11-04T18:48:46.250Z"
        )
    }
}
