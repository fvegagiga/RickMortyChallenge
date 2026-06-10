import Testing
@testable import RickMortyChallenge

@Suite
struct CharacterNavigationIntentTests {
    let mockStore: MockAppGroupStore

    init() {
        mockStore = MockAppGroupStore()
    }

    @Test
    func nextIndex_incrementsByOne() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 5
        let next = (mockStore.currentIndex() + 1) % mockStore.totalCount()
        #expect(next == 1)
    }

    @Test
    func nextIndex_wrapsToZeroAtEnd() {
        mockStore.stubbedCurrentIndex = 4
        mockStore.stubbedTotalCount = 5
        let next = (mockStore.currentIndex() + 1) % mockStore.totalCount()
        #expect(next == 0)
    }

    @Test
    func nextIndex_withSingleCharacter_staysAtZero() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 1
        let next = (mockStore.currentIndex() + 1) % mockStore.totalCount()
        #expect(next == 0)
    }

    @Test
    func previousIndex_decrementsByOne() {
        mockStore.stubbedCurrentIndex = 3
        mockStore.stubbedTotalCount = 5
        let previous = (mockStore.currentIndex() - 1 + mockStore.totalCount()) % mockStore.totalCount()
        #expect(previous == 2)
    }

    @Test
    func previousIndex_wrapsToLastAtStart() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 5
        let previous = (mockStore.currentIndex() - 1 + mockStore.totalCount()) % mockStore.totalCount()
        #expect(previous == 4)
    }

    @Test
    func previousIndex_withSingleCharacter_staysAtZero() {
        mockStore.stubbedCurrentIndex = 0
        mockStore.stubbedTotalCount = 1
        let previous = (mockStore.currentIndex() - 1 + mockStore.totalCount()) % mockStore.totalCount()
        #expect(previous == 0)
    }
}
