// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BadBehavior",
    defaultLocalization: "en",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.3")
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
    ],
    swiftLanguageModes: [.v6]
)

