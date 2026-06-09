import SwiftUI

/// Two-level cached image view: NSCache (memory) → FileManager (disk) → URLSession (network).
/// Accepts generic content and placeholder closures for full layout flexibility.
struct CachedAsyncImageView<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let cacheManager: ImageCacheManagerProtocol
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    init(
        url: URL?,
        cacheManager: ImageCacheManagerProtocol,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.cacheManager = cacheManager
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else { return }

        if let cached = cacheManager.image(for: url) {
            uiImage = cached
            return
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let downloaded = UIImage(data: data)
        else { return }

        cacheManager.store(downloaded, for: url)
        uiImage = downloaded
    }
}
