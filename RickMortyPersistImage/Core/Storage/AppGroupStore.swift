import Foundation

protocol AppGroupStoreProtocol: Sendable {
    func writeSnapshot(_ characters: [CharacterWidgetData])
    func downloadImages(for characters: [CharacterWidgetData]) async
    func currentCharacter() -> CharacterWidgetData?
    func currentIndex() -> Int
    func setCurrentIndex(_ index: Int)
    func totalCount() -> Int
    func imageURL(for characterId: Int) -> URL?
}

final class AppGroupStore: AppGroupStoreProtocol {

    static let appGroupIdentifier = "group.com.fvg0902iosdev.RickMortyPersistImage.widget"

    private enum Keys {
        static let characters = "widget.characters"
        static let currentIndex = "widget.currentIndex"
    }

    private let defaults: UserDefaults?
    private let urlSession: URLSession

    init(
        defaults: UserDefaults? = UserDefaults(suiteName: AppGroupStore.appGroupIdentifier),
        urlSession: URLSession = .shared
    ) {
        self.defaults = defaults
        self.urlSession = urlSession
    }

    // MARK: - Snapshot

    func writeSnapshot(_ characters: [CharacterWidgetData]) {
        guard let encoded = try? JSONEncoder().encode(characters) else { return }
        defaults?.set(encoded, forKey: Keys.characters)
        defaults?.set(0, forKey: Keys.currentIndex)
    }

    func currentCharacter() -> CharacterWidgetData? {
        let all = loadAll()
        guard !all.isEmpty else { return nil }
        let index = min(currentIndex(), all.count - 1)
        return all[index]
    }

    func currentIndex() -> Int {
        defaults?.integer(forKey: Keys.currentIndex) ?? 0
    }

    func setCurrentIndex(_ index: Int) {
        defaults?.set(index, forKey: Keys.currentIndex)
    }

    func totalCount() -> Int {
        loadAll().count
    }

    // MARK: - Image Storage

    func imageURL(for characterId: Int) -> URL? {
        imageContainerURL()?.appendingPathComponent("\(characterId).jpg")
    }

    func downloadImages(for characters: [CharacterWidgetData]) async {
        guard let containerURL = imageContainerURL() else { return }
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)

        await withTaskGroup(of: Void.self) { group in
            for character in characters {
                group.addTask { [weak self] in
                    await self?.downloadImageIfNeeded(character)
                }
            }
        }
    }

    // MARK: - Private

    private func loadAll() -> [CharacterWidgetData] {
        guard
            let data = defaults?.data(forKey: Keys.characters),
            let characters = try? JSONDecoder().decode([CharacterWidgetData].self, from: data)
        else { return [] }
        return characters
    }

    private func imageContainerURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroupStore.appGroupIdentifier)?
            .appendingPathComponent("Library/Caches/widget-images", isDirectory: true)
    }

    private func downloadImageIfNeeded(_ character: CharacterWidgetData) async {
        guard
            let source = character.imageURL,
            let destination = imageURL(for: character.id),
            !FileManager.default.fileExists(atPath: destination.path)
        else { return }

        guard let (data, _) = try? await urlSession.data(from: source) else { return }
        try? data.write(to: destination, options: .atomic)
    }
}
