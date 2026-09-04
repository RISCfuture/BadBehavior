// swift-tools-version: 6.3

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "BadBehavior",
  defaultLocalization: "en",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0")
  ],
  targets: [
    .target(
      name: "libBadBehavior",
      resources: [.process("Resources")],
      swiftSettings: upcomingFeatures
    ),
    .executableTarget(
      name: "BadBehavior",
      dependencies: [
        "libBadBehavior",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [.process("Resources")],
      swiftSettings: upcomingFeatures
    )
  ],
  swiftLanguageModes: [.v6]
)
