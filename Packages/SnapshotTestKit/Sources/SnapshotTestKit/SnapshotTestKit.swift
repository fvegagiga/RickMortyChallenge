import Foundation
import UIKit
import XCTest

public enum SnapshotTestKit {
    public static func assertSnapshot(
        of image: UIImage,
        named snapshotName: String,
        record: Bool,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        assertSnapshotData(
            image,
            named: snapshotName,
            record: record,
            file: file,
            testName: testName,
            line: line
        )
    }

    public static func assertSnapshot(
        of viewController: UIViewController,
        named snapshotName: String,
        record: Bool,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        assertSnapshotData(
            renderImage(from: viewController),
            named: snapshotName,
            record: record,
            file: file,
            testName: testName,
            line: line
        )
    }

    private static func assertSnapshotData(
        _ image: UIImage,
        named snapshotName: String,
        record: Bool,
        file: StaticString,
        testName: String,
        line: UInt
    ) {
        guard !isUniform(image) else {
            XCTFail("Captured snapshot is blank or uniform for \(snapshotName). Ensure the rendered view contains visible UI before asserting.", file: file, line: line)
            return
        }

        guard let imageData = image.pngData() else {
            XCTFail("Unable to encode snapshot PNG data.", file: file, line: line)
            return
        }

        let fileURL = URL(fileURLWithPath: "\(file)")
        let snapshotsDirectory = fileURL.deletingLastPathComponent().appendingPathComponent("__Snapshots__", isDirectory: true)
        let snapshotFileName = "\(sanitize(snapshotName)).png"
        let snapshotFileURL = snapshotsDirectory.appendingPathComponent(snapshotFileName)

        do {
            try FileManager.default.createDirectory(
                at: snapshotsDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            XCTFail("Unable to create snapshots folder: \(error)", file: file, line: line)
            return
        }

        if record || !FileManager.default.fileExists(atPath: snapshotFileURL.path) {
            writeSnapshot(imageData, to: snapshotFileURL, file: file, line: line)
            return
        }

        guard let baselineData = try? Data(contentsOf: snapshotFileURL) else {
            XCTFail("Unable to read baseline snapshot at \(snapshotFileURL.path)", file: file, line: line)
            return
        }

        guard baselineData == imageData else {
            let failedURL = snapshotsDirectory.appendingPathComponent("\(sanitize(snapshotName))_failed.png")
            writeSnapshot(imageData, to: failedURL, file: file, line: line)

            let baselineAttachment = XCTAttachment(data: baselineData, uniformTypeIdentifier: "public.png")
            baselineAttachment.name = "Baseline"
            baselineAttachment.lifetime = .keepAlways

            let failedAttachment = XCTAttachment(data: imageData, uniformTypeIdentifier: "public.png")
            failedAttachment.name = "Current"
            failedAttachment.lifetime = .keepAlways

            XCTContext.runActivity(named: "Snapshot mismatch") { activity in
                activity.add(baselineAttachment)
                activity.add(failedAttachment)
            }

            XCTFail(
                "Snapshot mismatch for \(snapshotName). Baseline: \(snapshotFileURL.path), Current: \(failedURL.path)",
                file: file,
                line: line
            )
            return
        }
    }

    private static func renderImage(from viewController: UIViewController) -> UIImage {
        let bounds = CGRect(origin: .zero, size: viewController.view.bounds.size)
        let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: UIScreen.main.scale))
        format.scale = UIScreen.main.scale

        return autoreleasepool {
            UIGraphicsImageRenderer(bounds: bounds, format: format).image { context in
                viewController.view.layer.render(in: context.cgContext)
                context.cgContext.flush()
            }
        }
    }

    private static func isUniform(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return true }

        let sampleWidth = 32
        let sampleHeight = 32
        let bytesPerPixel = 4
        let bytesPerRow = sampleWidth * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: sampleHeight * bytesPerRow)

        guard let context = CGContext(
            data: &pixels,
            width: sampleWidth,
            height: sampleHeight,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return true
        }

        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleWidth, height: sampleHeight))

        let firstPixel = Array(pixels[0..<bytesPerPixel])
        let tolerance = 3

        for index in stride(from: bytesPerPixel, to: pixels.count, by: bytesPerPixel) {
            let currentPixel = pixels[index..<(index + bytesPerPixel)]
            for channel in 0..<bytesPerPixel {
                if abs(Int(currentPixel[currentPixel.startIndex + channel]) - Int(firstPixel[channel])) > tolerance {
                    return false
                }
            }
        }

        return true
    }

    private static func writeSnapshot(
        _ data: Data,
        to fileURL: URL,
        file: StaticString,
        line: UInt
    ) {
        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            XCTFail("Unable to write snapshot file at \(fileURL.path): \(error)", file: file, line: line)
        }
    }

    private static func sanitize(_ value: String) -> String {
        value.replacingOccurrences(of: "[^A-Za-z0-9_\\-\\.]", with: "_", options: .regularExpression)
    }
}
