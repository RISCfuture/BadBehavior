# Validating Flights

Learn how to use the Validator actor to check flights for regulatory violations.

## Overview

The `Validator` actor analyzes your flight history to identify potential FAR violations. It processes flights concurrently for optimal performance.

## Creating a Validator

Initialize a Validator with your flight array:

```swift
let validator = Validator(flights: flights)
```

The Validator automatically sorts flights chronologically for proper currency tracking.

## Running Validation

Call `violations()` to check all flights:

```swift
let violations = try await validator.violations()
```

This returns an array of `Violations` objects, each containing:
- The flight that has violations
- An array of `Violation` cases describing each issue

## How Validation Works

The Validator uses a plugin architecture with specialized checkers:

1. **NoFlightReview** - Checks FAR 61.56(c) flight review currency
2. **NoPassengerCurrency** - Checks FAR 61.57(a) takeoff/landing requirements
3. **NoNightPassengerCurrency** - Checks FAR 61.57(b) night requirements
4. **NoIFRCurrency** - Checks FAR 61.57(c) instrument currency
5. **NoProficiencyCheck** - Checks FAR 61.58(a)(1) proficiency requirements
6. **NoProficiencyCheckInType** - Checks FAR 61.58(a)(2) type-specific requirements
7. **NoNVGCurrency** - Checks FAR 61.57(f) NVG currency
8. **NoNVGPassengerCurrency** - Checks FAR 61.57(f) NVG passenger currency
9. **DualGiven8In24** - Checks FAR 61.195(a) CFI time limits
10. **DualGivenTimeInType** - Checks FAR 61.195(f) CFI type experience

Each checker runs in parallel across all flights for maximum performance.

## Processing Results

```swift
let violations = try await validator.violations()
    .sorted { $0.flight.date < $1.flight.date }

for v in violations {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short

    print("\(dateFormatter.string(from: v.flight.date))")
    print("Aircraft: \(v.flight.aircraft?.registration ?? "Unknown")")
    print("Route: \(v.flight.from?.identifier ?? "???") -> \(v.flight.to?.identifier ?? "???")")

    for violation in v.violations {
        print("  - \(violation)")
    }
}
```

## Concurrency Model

The Validator is an actor to ensure thread-safe operation. The validation process:
1. Sets up each checker with the complete flight list
2. Iterates through flights, checking each against all rules
3. Collects violations using Swift Concurrency task groups
