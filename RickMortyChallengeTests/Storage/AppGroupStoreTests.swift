import Foundation
import Testing
@testable import RickMortyChallenge

@Suite
struct AppGroupStoreTests {
    let sut: AppGroupStore
    let testDefaults: UserDefaults

    init() {
        testDefaults = UserDefaults(suiteName: "test.appgroupstore.\(UUID().uuidString)")!
        sut = AppGroupStore(defaults: testDefaults)
    }

    @Test
    func writeSnapshot_persistsCharacters() async {
        let characters = makeCharacters(count: 3)
        await sut.writeSnapshot(characters)
        #expect(sut.totalCount() == 3)
    }

    @Test
    func writeSnapshot_resetsIndexToZero() async {
        sut.setCurrentIndex(5)
        await sut.writeSnapshot(makeCharacters(count: 3))
        #expect(sut.currentIndex() == 0)
    }

    @Test
    func writeSnapshot_overwritesPreviousSnapshot() async {
        await sut.writeSnapshot(makeCharacters(count: 5))
        await sut.writeSnapshot(makeCharacters(count: 2))
        #expect(sut.totalCount() == 2)
    }

    @Test
    func currentCharacter_returnsNilWhenEmpty() {
        #expect(sut.currentCharacter() == nil)
    }

    @Test
    func currentCharacter_returnsFirstByDefault() async {
        let characters = makeCharacters(count: 3)
        await sut.writeSnapshot(characters)
        #expect(sut.currentCharacter()?.id == characters[0].id)
    }

    @Test
    func currentCharacter_respectsCurrentIndex() async {
        let characters = makeCharacters(count: 3)
        await sut.writeSnapshot(characters)
        sut.setCurrentIndex(2)
        #expect(sut.currentCharacter()?.id == characters[2].id)
    }

    @Test
    func setCurrentIndex_persistsValue() async {
        await sut.writeSnapshot(makeCharacters(count: 5))
        sut.setCurrentIndex(3)
        #expect(sut.currentIndex() == 3)
    }

    @Test
    func currentIndex_returnsZeroWhenNeverSet() {
        #expect(sut.currentIndex() == 0)
    }

    @Test
    func totalCount_returnsZeroWhenEmpty() {
        #expect(sut.totalCount() == 0)
    }

    @Test
    func totalCount_matchesWrittenSnapshot() async {
        await sut.writeSnapshot(makeCharacters(count: 7))
        #expect(sut.totalCount() == 7)
    }

    @Test
    func imageURL_returnsNilWhenContainerUnavailable() {
        let store = AppGroupStore(defaults: nil)
        #expect(store.imageURL(for: 1) == nil)
    }

    @Test
    func characterWidgetData_decodesLegacyPayloadWithoutStatus_defaultsToEmptyString() throws {
        let legacyJSON = """
        [{"id":1,"name":"Rick","imageFileName":"1.jpg"}]
        """.data(using: .utf8)!
        let characters = try JSONDecoder().decode([CharacterWidgetData].self, from: legacyJSON)
        #expect(characters[0].status == "")
    }

    @Test
    func characterWidgetData_encodesAndDecodesStatusRoundTrip() throws {
        let original = CharacterWidgetData(id: 1, name: "Rick", imageFileName: "1.jpg", imageURL: nil, status: "Alive")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CharacterWidgetData.self, from: data)
        #expect(decoded.status == "Alive")
    }

    private func makeCharacters(count: Int) -> [CharacterWidgetData] {
        (1...count).map { i in
            CharacterWidgetData(id: i, name: "Character \(i)", imageFileName: "\(i).jpg", imageURL: nil)
        }
    }
}
