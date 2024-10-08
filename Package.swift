// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "BadBehavior",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.2.0")
    ],
    targets: [
        .target(name: "libBadBehavior",
                dependencies: [
                    .product(name: "GRDB", package: "GRDB.swift")
                ]),
        .executableTarget(name: "BadBehavior",
                          dependencies: [
                            "libBadBehavior",
                            .product(name: "ArgumentParser", package: "swift-argument-parser")
                          ])
    ]
)

