import Testing
import UIKit
@testable import RickMortyChallenge

@Suite
struct ImageCacheManagerTests {
    private func makeSUT() -> ImageCacheManager {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("image-cache-tests.\(UUID().uuidString)", isDirectory: true)
        return ImageCacheManager(cacheDirectory: directory)
    }

    private func makeImage(color: UIColor = .red, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    @Test
    func image_returnsNilForMiss() async {
        let sut = makeSUT()
        let url = URL(string: "https://example.com/missing.jpg")!

        let result = await sut.image(for: url)

        #expect(result == nil)
    }

    @Test
    func store_thenImage_returnsMemoryHit() async {
        let sut = makeSUT()
        let url = URL(string: "https://example.com/memory.jpg")!
        let image = makeImage(color: .blue)

        await sut.store(image, for: url)
        let result = await sut.image(for: url)

        #expect(result != nil)
    }

    @Test
    func store_thenClear_returnsNil() async {
        let sut = makeSUT()
        let url = URL(string: "https://example.com/clear.jpg")!
        let image = makeImage(color: .green)

        await sut.store(image, for: url)
        await sut.clearCache()
        let result = await sut.image(for: url)

        #expect(result == nil)
    }

    @Test
    func store_promotesFromDiskAfterMemoryEviction() async throws {
        let sut = makeSUT()
        let url = URL(string: "https://example.com/disk.jpg")!
        let image = makeImage(color: .orange)

        await sut.store(image, for: url)
        await sut.clearMemoryCacheForTesting()
        let result = await sut.image(for: url)

        #expect(result != nil)
    }

    @Test
    func parallelStoreAndRead_completesWithoutCrash() async {
        let sut = makeSUT()
        let urls = (0..<20).map { URL(string: "https://example.com/parallel-\($0).jpg")! }
        let expectedSizes = urls.enumerated().map { index, _ in
            CGSize(width: 10 + index, height: 10 + index)
        }

        await withTaskGroup(of: Void.self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let image = self.makeImage(
                        color: index.isMultiple(of: 2) ? .red : .blue,
                        size: expectedSizes[index]
                    )
                    await sut.store(image, for: url)
                    _ = await sut.image(for: url)
                }
            }
        }

        for (index, url) in urls.enumerated() {
            let image = await sut.image(for: url)
            #expect(image?.size == expectedSizes[index])
        }
    }
}
