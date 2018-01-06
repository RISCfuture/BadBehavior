// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "BadBehavior",
    dependencies: [
      .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.11.4")
    ],
    targets: [
        .target(name: "BadBehavior", dependencies: ["SQLite"])
    ]
)
