import Foundation
import Testing
import UIKit
@testable import RickMortyChallenge

@Suite(.serialized)
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

    @Test
    func downloadImages_skipsExistingFile() async throws {
        let context = try makeDownloadTestContext()
        defer { context.cleanup() }

        let destination = try #require(context.store.imageURL(for: 1))
        try Data([0xFF, 0xD8, 0xFF, 0xD9]).write(to: destination)

        let character = CharacterWidgetData(
            id: 1,
            name: "Rick",
            imageFileName: "1.jpg",
            imageURL: URL(string: "https://example.com/1.jpg")
        )
        await context.store.downloadImages(for: [character])

        #expect(StubURLProtocol.requestCount == 0)
    }

    @Test
    func downloadImages_downloadsWhenMissing() async throws {
        let context = try makeDownloadTestContext()
        defer { context.cleanup() }

        let imageData = try #require(makeTestJPEGData())
        StubURLProtocol.reset { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let character = CharacterWidgetData(
            id: 2,
            name: "Morty",
            imageFileName: "2.jpg",
            imageURL: URL(string: "https://example.com/2.jpg")
        )
        await context.store.downloadImages(for: [character])

        let destination = try #require(context.store.imageURL(for: 2))
        #expect(FileManager.default.fileExists(atPath: destination.path))
        #expect(StubURLProtocol.requestCount == 1)
    }

    @Test
    func downloadImages_parallelCompletion() async throws {
        let context = try makeDownloadTestContext()
        defer { context.cleanup() }

        let imageData = try #require(makeTestJPEGData())
        StubURLProtocol.reset { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let characters = (1...4).map { index in
            CharacterWidgetData(
                id: index,
                name: "Character \(index)",
                imageFileName: "\(index).jpg",
                imageURL: URL(string: "https://example.com/\(index).jpg")
            )
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await context.store.downloadImages(for: Array(characters.prefix(2))) }
            group.addTask { await context.store.downloadImages(for: Array(characters.suffix(2))) }
        }

        for character in characters {
            let destination = try #require(context.store.imageURL(for: character.id))
            #expect(FileManager.default.fileExists(atPath: destination.path))
        }
        #expect(StubURLProtocol.requestCount == 4)
    }

    private func makeCharacters(count: Int) -> [CharacterWidgetData] {
        (1...count).map { i in
            CharacterWidgetData(id: i, name: "Character \(i)", imageFileName: "\(i).jpg", imageURL: nil)
        }
    }

    private func makeDownloadTestContext() throws -> DownloadTestContext {
        let defaults = UserDefaults(suiteName: "test.appgroupstore.download.\(UUID().uuidString)")!
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("widget-images.\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        StubURLProtocol.reset { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let store = AppGroupStore(
            defaults: defaults,
            urlSession: StubURLProtocol.makeSession(),
            imageCacheDirectory: cacheDirectory
        )
        return DownloadTestContext(store: store, cacheDirectory: cacheDirectory)
    }

    private func makeTestJPEGData() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let image = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        return image.jpegData(compressionQuality: 0.9)
    }

    private struct DownloadTestContext {
        let store: AppGroupStore
        let cacheDirectory: URL

        func cleanup() {
            try? FileManager.default.removeItem(at: cacheDirectory)
            StubURLProtocol.reset()
        }
    }
}
