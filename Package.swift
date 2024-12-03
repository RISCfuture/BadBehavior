// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BadBehavior",
    defaultLocalization: "en",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .target(name: "libBadBehavior",
                resources: [.copy("Localizable.xcstrings")]),
        .executableTarget(name: "BadBehavior",
                          dependencies: [
                            "libBadBehavior",
                            .product(name: "ArgumentParser", package: "swift-argument-parser")
                          ],
                          resources: [.copy("Localizable.xcstrings")])
    ],
    swiftLanguageModes: [.v6]
)

