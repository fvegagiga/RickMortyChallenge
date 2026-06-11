import Foundation

protocol AppGroupStoreProtocol: Sendable {
    func writeSnapshot(_ characters: [CharacterWidgetData]) async
    func downloadImages(for characters: [CharacterWidgetData]) async
    nonisolated func currentCharacter() -> CharacterWidgetData?
    nonisolated func currentIndex() -> Int
    nonisolated func setCurrentIndex(_ index: Int)
    nonisolated func totalCount() -> Int
    nonisolated func imageURL(for characterId: Int) -> URL?
}

actor AppGroupStore: AppGroupStoreProtocol {

    static let appGroupIdentifier = "group.com.fvg0902iosdev.RickMortyChallenge.widget"

    /// Widget snapshot state uses two UserDefaults keys: `widget.characters` (JSON snapshot)
    /// and `widget.currentIndex`. `writeSnapshot` resets the index when updating characters.
    /// Cross-key atomicity is best-effort via write ordering, not transactional.
    /// Widget-facing reads remain `nonisolated` because WidgetKit requires synchronous access.
    private enum Keys {
        static let characters = "widget.characters"
        static let currentIndex = "widget.currentIndex"
    }

    nonisolated private let defaults: UserDefaults?
    nonisolated private let urlSession: URLSession
    nonisolated private let imageCacheDirectoryOverride: URL?

    init(
        defaults: UserDefaults? = UserDefaults(suiteName: AppGroupStore.appGroupIdentifier),
        urlSession: URLSession = .shared,
        imageCacheDirectory: URL? = nil
    ) {
        self.defaults = defaults
        self.urlSession = urlSession
        self.imageCacheDirectoryOverride = imageCacheDirectory
    }

    // MARK: - Snapshot

    func writeSnapshot(_ characters: [CharacterWidgetData]) async {
        guard let encoded = try? JSONEncoder().encode(characters) else { return }
        defaults?.set(encoded, forKey: Keys.characters)
        defaults?.set(0, forKey: Keys.currentIndex)
    }

    nonisolated func currentCharacter() -> CharacterWidgetData? {
        let all = loadAll()
        guard !all.isEmpty else { return nil }
        let index = min(currentIndex(), all.count - 1)
        return all[index]
    }

    nonisolated func currentIndex() -> Int {
        defaults?.integer(forKey: Keys.currentIndex) ?? 0
    }

    nonisolated func setCurrentIndex(_ index: Int) {
        defaults?.set(index, forKey: Keys.currentIndex)
    }

    nonisolated func totalCount() -> Int {
        loadAll().count
    }

    // MARK: - Image Storage

    nonisolated func imageURL(for characterId: Int) -> URL? {
        guard defaults != nil else { return nil }
        return imageContainerURL()?.appendingPathComponent("\(characterId).jpg")
    }

    func downloadImages(for characters: [CharacterWidgetData]) async {
        guard let containerURL = imageContainerURL() else { return }
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)

        await withTaskGroup(of: Void.self) { group in
            for character in characters {
                group.addTask { [urlSession] in
                    await self.downloadImageIfNeeded(character, urlSession: urlSession)
                }
            }
        }
    }

    // MARK: - Private

    nonisolated private func loadAll() -> [CharacterWidgetData] {
        guard
            let data = defaults?.data(forKey: Keys.characters),
            let characters = try? JSONDecoder().decode([CharacterWidgetData].self, from: data)
        else { return [] }
        return characters
    }

    nonisolated private func imageContainerURL() -> URL? {
        if let imageCacheDirectoryOverride {
            return imageCacheDirectoryOverride
        }
        return FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroupStore.appGroupIdentifier)?
            .appendingPathComponent("Library/Caches/widget-images", isDirectory: true)
    }

    private func downloadImageIfNeeded(_ character: CharacterWidgetData, urlSession: URLSession) async {
        guard
            let source = character.imageURL,
            let destination = imageURL(for: character.id),
            !FileManager.default.fileExists(atPath: destination.path)
        else { return }

        guard let (data, _) = try? await urlSession.data(from: source) else { return }
        try? data.write(to: destination, options: .atomic)
    }
}
