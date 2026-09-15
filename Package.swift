// swift-tools-version: 6.4

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .strictMemorySafety()
]

let package = Package(
  name: "BadBehavior",
  defaultLocalization: "en",
  platforms: [.macOS(.v27)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0")
  ],
  targets: [
    .target(
      name: "libBadBehavior",
      resources: [.process("Resources")],
      swiftSettings: swiftSettings
    ),
    .executableTarget(
      name: "BadBehavior",
      dependencies: [
        "libBadBehavior",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [.process("Resources")],
      swiftSettings: swiftSettings
    )
  ],
  swiftLanguageModes: [.v6]
)
