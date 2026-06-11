import UIKit

protocol ImageCacheManagerProtocol: Sendable {
    func image(for url: URL) async -> UIImage?
    func store(_ image: UIImage, for url: URL) async
    func clearCache() async
}

actor ImageCacheManager: ImageCacheManagerProtocol {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL
    private let fileManager: FileManager

    init(cacheDirectory: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let baseDirectory = cacheDirectory
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("com.rickmorty.imagecache", isDirectory: true)
        self.cacheDirectory = baseDirectory
        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        memoryCache.countLimit = 150
        memoryCache.totalCostLimit = 75 * 1_024 * 1_024
    }

    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)

        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        let filePath = cacheDirectory.appendingPathComponent(key)
        guard
            let data = try? Data(contentsOf: filePath),
            let image = UIImage(data: data)
        else { return nil }

        memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
        return image
    }

    func store(_ image: UIImage, for url: URL) async {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString)

        let filePath = cacheDirectory.appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: filePath)
        }
    }

    func clearCache() async {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    #if DEBUG
    func clearMemoryCacheForTesting() {
        memoryCache.removeAllObjects()
    }
    #endif

    private func cacheKey(for url: URL) -> String {
        url.absoluteString
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "-")
    }
}
