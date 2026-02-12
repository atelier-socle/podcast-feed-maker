// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PodcastFeedMaker",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
        .macCatalyst(.v16)
    ],
    products: [
        .library(
            name: "PodcastFeedMaker",
            targets: ["PodcastFeedMaker"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "PodcastFeedMaker"),
        .testTarget(
            name: "PodcastFeedMakerTests",
            dependencies: ["PodcastFeedMaker"],
            resources: [.copy("Fixtures")]
        )
    ]
)
