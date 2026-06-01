// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IronRank",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "IronRank",
            path: "Sources/IronRank",
            exclude: [
                "Resources",
                "Views",
                "ViewModels",
                "Utilities/Haptics.swift"
            ]
        )
    ]
)
