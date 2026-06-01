// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IronRank",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IronRank",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "IronRankTests",
            dependencies: ["IronRank"]
        )
    ]
)
