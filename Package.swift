// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "BadBehavior",
  defaultLocalization: "en",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
  ],
  targets: [
    .target(
      name: "libBadBehavior",
      resources: [.process("Resources")]
    ),
    .executableTarget(
      name: "BadBehavior",
      dependencies: [
        "libBadBehavior",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [.process("Resources")]
    )
  ],
  swiftLanguageModes: [.v6]
)
