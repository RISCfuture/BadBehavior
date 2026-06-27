// swift-tools-version: 6.3

import PackageDescription

let approachableConcurrency: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances")
]

let package = Package(
  name: "BadBehavior",
  defaultLocalization: "en",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")
  ],
  targets: [
    .target(
      name: "libBadBehavior",
      resources: [.process("Resources")],
      swiftSettings: approachableConcurrency
    ),
    .executableTarget(
      name: "BadBehavior",
      dependencies: [
        "libBadBehavior",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [.process("Resources")],
      swiftSettings: approachableConcurrency
    )
  ],
  swiftLanguageModes: [.v6]
)
