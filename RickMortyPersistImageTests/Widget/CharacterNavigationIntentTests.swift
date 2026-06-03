import XCTest
@testable import RickMortyPersistImage

final class CharacterNavigationIntentTests: XCTestCase {
    var mockStore: MockAppGroupStore!

    override func setUp() {
        super.setUp()
        mockStore = MockAppGroupStore()
    }

    override func tearDown() {
        mockStore = nil
        super.tearDown()
    }

    // MARK: - Next index logic

    func testNextIndex_incrementsByOne() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 5
        let next = (mockStore.currentIndex() + 1) % mockStore.totalCount()
        XCTAssertEqual(next, 1)
    }

    func testNextIndex_wrapsToZeroAtEnd() {
        mockStore.stubbedCurrentIndex = 4
        mockStore.stubbedTotalCount = 5
        let next = (mockStore.currentIndex() + 1) % mockStore.totalCount()
        XCTAssertEqual(next, 0)
    }

    func testNextIndex_withSingleCharacter_staysAtZero() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 1
        let next = (mockStore.currentIndex() + 1) % mockStore.totalCount()
        XCTAssertEqual(next, 0)
    }

    // MARK: - Previous index logic

    func testPreviousIndex_decrementsByOne() {
        mockStore.stubbedCurrentIndex = 3
        mockStore.stubbedTotalCount = 5
        let previous = (mockStore.currentIndex() - 1 + mockStore.totalCount()) % mockStore.totalCount()
        XCTAssertEqual(previous, 2)
    }

    func testPreviousIndex_wrapsToLastAtStart() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 5
        let previous = (mockStore.currentIndex() - 1 + mockStore.totalCount()) % mockStore.totalCount()
        XCTAssertEqual(previous, 4)
    }

    func testPreviousIndex_withSingleCharacter_staysAtZero() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 1
        let previous = (mockStore.currentIndex() - 1 + mockStore.totalCount()) % mockStore.totalCount()
        XCTAssertEqual(previous, 0)
    }
}
