# Understanding Violations

A comprehensive guide to the FAR violations detected by BadBehavior.

## Overview

BadBehavior checks for ten different types of regulatory violations related to pilot currency and instructor limitations.

## Flight Review Currency

### noFlightReview - FAR 61.56(c)

A pilot may not act as pilot in command unless they have completed a flight review within the preceding 24 calendar months.

**Triggering conditions:**
- Flight logged as PIC
- Not dual received, student solo, flight review, or checkride
- No flight review or checkride within prior 24 calendar months

## Passenger Currency

### noPassengerCurrency - FAR 61.57(a)

To carry passengers, a pilot must have made 3 takeoffs and landings within the preceding 90 days in the same category and class.

**Additional requirements:**
- Tailwheel aircraft require full-stop landings
- Type-rated aircraft require landings in type

### noNightPassengerCurrency - FAR 61.57(b)

To carry passengers at night, a pilot must have made 3 takeoffs and full-stop landings at night within the preceding 90 days.

**Triggering conditions:**
- Flight has night time
- Flight has passengers
- Insufficient night takeoffs/full-stop landings in category/class

## Instrument Currency

### noIFRCurrency - FAR 61.57(c)

To fly under IFR, a pilot must have completed within the preceding 6 calendar months:
- Six instrument approaches
- Holding procedures
- Intercepting and tracking courses

**Grace period:** If currency lapses, approaches and holds in the next 6 months can restore currency if they meet the requirements.

## Type Rating Currency

### noPPC - FAR 61.58(a)(1)

Pilots of aircraft requiring a type rating must complete a proficiency check within the preceding 24 calendar months.

### noPPCInType - FAR 61.58(a)(2)

The proficiency check must be in the same type of aircraft (or approved simulator).

## NVG Currency

### noNVGCurrency - FAR 61.57(f)

To act as PIC using NVGs, pilots must have completed within the preceding 4 calendar months:
- 3 NVG takeoffs and landings
- OR a proficiency check

### noNVGPassengerCurrency - FAR 61.57(f)

Additional requirements apply when carrying passengers under NVGs:
- 3 NVG takeoffs and landings within preceding 2 calendar months
- OR a proficiency check

## CFI Limitations

### dualGiven8in24 - FAR 61.195(a)

A flight instructor may not conduct more than 8 hours of flight training in any 24-consecutive-hour period.

### dualGivenTimeInType - FAR 61.195(f)

To give training in a multiengine airplane, helicopter, or powered-lift aircraft, the instructor must have at least 5 flight hours in the specific make and model.

## Working with Violation Results

```swift
let violations = try await validator.violations()

for v in violations {
    for violation in v.violations {
        switch violation {
        case .noFlightReview:
            print("FAR 61.56(c) - Flight review required")
        case .noPassengerCurrency:
            print("FAR 61.57(a) - Complete 3 takeoffs/landings")
        case .noNightPassengerCurrency:
            print("FAR 61.57(b) - Complete 3 night takeoffs/full-stops")
        case .noIFRCurrency:
            print("FAR 61.57(c) - Complete IPC or 6 approaches + hold")
        case .noPPC:
            print("FAR 61.58(a)(1) - Proficiency check required")
        case .noPPCInType:
            print("FAR 61.58(a)(2) - Proficiency check required in type")
        case .noNVGCurrency:
            print("FAR 61.57(f) - NVG currency required")
        case .noNVGPassengerCurrency:
            print("FAR 61.57(f) - NVG passenger currency required")
        case .dualGiven8in24:
            print("FAR 61.195(a) - Exceeded 8 hours dual given")
        case .dualGivenTimeInType:
            print("FAR 61.195(f) - Need 5 hours in type")
        }
    }
}
```
