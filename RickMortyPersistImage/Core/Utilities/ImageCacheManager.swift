import UIKit

protocol ImageCacheManagerProtocol {
    func image(for url: URL) -> UIImage?
    func store(_ image: UIImage, for url: URL)
    func clearCache()
}

final class ImageCacheManager: ImageCacheManagerProtocol {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL

    init() {
        let baseDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = baseDir.appendingPathComponent("com.rickmorty.imagecache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        memoryCache.countLimit = 150
        memoryCache.totalCostLimit = 75 * 1_024 * 1_024
    }

    func image(for url: URL) -> UIImage? {
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

    func store(_ image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString)

        let filePath = cacheDirectory.appendingPathComponent(key)
        Task(priority: .background) {
            image.jpegData(compressionQuality: 0.85).map { try? $0.write(to: filePath) }
        }
    }

    func clearCache() {
        memoryCache.removeAllObjects()
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func cacheKey(for url: URL) -> String {
        url.absoluteString
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "-")
    }
}
