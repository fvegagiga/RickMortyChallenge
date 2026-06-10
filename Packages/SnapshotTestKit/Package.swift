// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SnapshotTestKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SnapshotTestKit",
            targets: ["SnapshotTestKit"]
        )
    ],
    targets: [
        .target(
            name: "SnapshotTestKit"
        )
    ]
)
