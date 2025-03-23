// swift-tools-version: 6.0
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
            targets: ["PodcastFeedMaker"]),
    ],
    targets: [
        .target(
            name: "PodcastFeedMaker"),
        .testTarget(
            name: "PodcastFeedMakerTests",
            dependencies: ["PodcastFeedMaker"]
        )
    ]
)
