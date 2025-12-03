# Getting Started with libBadBehavior

Learn how to integrate libBadBehavior into your project and scan your LogTen logbook for regulatory violations.

## Overview

libBadBehavior is a Swift library that reads your LogTen Pro for Mac logbook and identifies flights that may have violated FAR Part 61 and 91 regulations.

## Prerequisites

Before using libBadBehavior, ensure you have:
- macOS 13 or later
- LogTen Pro for Mac installed with your logbook data
- Swift 6.0 or later

### LogTen Pro Configuration

Your LogTen Pro installation requires specific custom fields:

#### Flight Custom Fields
- **Night Full Stops** (Custom Landings) - For tracking night currency
- **FAR 61.58** (Custom Notes) - For marking proficiency check flights
- **Checkride** (Custom Notes) - For marking checkride flights
- **FAR 61.31(k)** (Custom Notes) - For NVG proficiency checks

#### Flight Crew Custom Roles
- **Safety Pilot** (Custom Role)
- **Examiner** (Custom Role)

#### Aircraft Type Custom Fields
- **Type Code** - FAA type designator
- **Sim Type** - BATD, AATD, FTD, or FFS
- **Sim A/C Cat** - ASEL, ASES, AMEL, AMES, or GL

## Adding to Your Project

Add libBadBehavior as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RISCfuture/BadBehavior.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["libBadBehavior"]
    )
]
```

## Basic Usage

Here's a minimal example that reads your logbook and checks for violations:

```swift
import libBadBehavior

// Default LogTen Pro paths
let homeDir = FileManager.default.homeDirectoryForCurrentUser
let storeURL = homeDir.appendingPathComponent(
    "Library/Group Containers/group.com.coradine.LogTenPro/LogTenProData_.../LogTenCoreDataStore.sql"
)
let modelURL = URL.applicationDirectory.appending(
    path: "LogTen.app/Contents/Resources/CNLogBookDocument.momd"
)

// Read flights
let reader = try await Reader(storeURL: storeURL, modelURL: modelURL)
let flights = try await reader.read()

// Validate
let validator = Validator(flights: flights)
let violations = try await validator.violations()

// Process results
for v in violations {
    print("\(v.flight.date): \(v.violations.count) violations")
}
```

## Next Steps

- <doc:ReadingLogTenData> - Learn more about the Reader class
- <doc:ValidatingFlights> - Understand the validation process
- <doc:UnderstandingViolations> - Explore all violation types
