// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RecommendationCatalogKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RecommendationCatalogKit",
            targets: ["RecommendationCatalogKit"]
        )
    ],
    targets: [
        .target(
            name: "RecommendationCatalogKit",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "RecommendationCatalogKitTests",
            dependencies: ["RecommendationCatalogKit"]
        )
    ]
)
