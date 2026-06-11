import Foundation
@testable import RickMortyChallenge

final class MockAppGroupStore: AppGroupStoreProtocol, @unchecked Sendable {
    var writtenSnapshot: [CharacterWidgetData]?
    var writeSnapshotCallCount = 0
    var downloadImagesCallCount = 0
    var stubbedCurrentCharacter: CharacterWidgetData?
    var stubbedCurrentIndex = 0
    var stubbedTotalCount = 0

    func writeSnapshot(_ characters: [CharacterWidgetData]) async {
        writtenSnapshot = characters
        writeSnapshotCallCount += 1
    }

    func downloadImages(for characters: [CharacterWidgetData]) async {
        downloadImagesCallCount += 1
    }

    func currentCharacter() -> CharacterWidgetData? { stubbedCurrentCharacter }
    func currentIndex() -> Int { stubbedCurrentIndex }
    func setCurrentIndex(_ index: Int) { stubbedCurrentIndex = index }
    func totalCount() -> Int { stubbedTotalCount }
    func imageURL(for characterId: Int) -> URL? { nil }
}
