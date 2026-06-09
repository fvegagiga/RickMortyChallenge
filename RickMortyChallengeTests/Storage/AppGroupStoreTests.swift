import XCTest
@testable import RickMortyChallenge

final class AppGroupStoreTests: XCTestCase {
    var sut: AppGroupStore!
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: "test.appgroupstore.\(UUID().uuidString)")
        sut = AppGroupStore(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testDefaults.description)
        sut = nil
        testDefaults = nil
        super.tearDown()
    }

    // MARK: - writeSnapshot

    func testWriteSnapshot_persistsCharacters() {
        let characters = makeCharacters(count: 3)
        sut.writeSnapshot(characters)
        XCTAssertEqual(sut.totalCount(), 3)
    }

    func testWriteSnapshot_resetsIndexToZero() {
        sut.setCurrentIndex(5)
        sut.writeSnapshot(makeCharacters(count: 3))
        XCTAssertEqual(sut.currentIndex(), 0)
    }

    func testWriteSnapshot_overwritesPreviousSnapshot() {
        sut.writeSnapshot(makeCharacters(count: 5))
        sut.writeSnapshot(makeCharacters(count: 2))
        XCTAssertEqual(sut.totalCount(), 2)
    }

    // MARK: - currentCharacter

    func testCurrentCharacter_returnsNilWhenEmpty() {
        XCTAssertNil(sut.currentCharacter())
    }

    func testCurrentCharacter_returnsFirstByDefault() {
        let characters = makeCharacters(count: 3)
        sut.writeSnapshot(characters)
        XCTAssertEqual(sut.currentCharacter()?.id, characters[0].id)
    }

    func testCurrentCharacter_respectsCurrentIndex() {
        let characters = makeCharacters(count: 3)
        sut.writeSnapshot(characters)
        sut.setCurrentIndex(2)
        XCTAssertEqual(sut.currentCharacter()?.id, characters[2].id)
    }

    // MARK: - setCurrentIndex / currentIndex

    func testSetCurrentIndex_persistsValue() {
        sut.writeSnapshot(makeCharacters(count: 5))
        sut.setCurrentIndex(3)
        XCTAssertEqual(sut.currentIndex(), 3)
    }

    func testCurrentIndex_returnsZeroWhenNeverSet() {
        XCTAssertEqual(sut.currentIndex(), 0)
    }

    // MARK: - totalCount

    func testTotalCount_returnsZeroWhenEmpty() {
        XCTAssertEqual(sut.totalCount(), 0)
    }

    func testTotalCount_matchesWrittenSnapshot() {
        sut.writeSnapshot(makeCharacters(count: 7))
        XCTAssertEqual(sut.totalCount(), 7)
    }

    // MARK: - imageURL

    func testImageURL_returnsNilWhenContainerUnavailable() {
        let store = AppGroupStore(defaults: nil)
        XCTAssertNil(store.imageURL(for: 1))
    }

    // MARK: - CharacterWidgetData backward compatibility

    func testCharacterWidgetData_decodesLegacyPayloadWithoutStatus_defaultsToEmptyString() throws {
        let legacyJSON = """
        [{"id":1,"name":"Rick","imageFileName":"1.jpg"}]
        """.data(using: .utf8)!
        let characters = try JSONDecoder().decode([CharacterWidgetData].self, from: legacyJSON)
        XCTAssertEqual(characters[0].status, "")
    }

    func testCharacterWidgetData_encodesAndDecodesStatusRoundTrip() throws {
        let original = CharacterWidgetData(id: 1, name: "Rick", imageFileName: "1.jpg", imageURL: nil, status: "Alive")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CharacterWidgetData.self, from: data)
        XCTAssertEqual(decoded.status, "Alive")
    }

    // MARK: - Helpers

    private func makeCharacters(count: Int) -> [CharacterWidgetData] {
        (1...count).map { i in
            CharacterWidgetData(id: i, name: "Character \(i)", imageFileName: "\(i).jpg", imageURL: nil)
        }
    }
}
