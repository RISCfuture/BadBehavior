# ``BadBehavior``

A command-line tool and library for scanning your LogTen Pro logbook for FAR Part 91 regulation violations.

@Metadata {
    @DisplayName("BadBehavior")
}

## Overview

BadBehavior reads your LogTen Pro for Mac logbook and identifies flights that may have violated FAR Part 61 and 91 regulations.

The tool checks for violations of:
- **FAR 61.56(c)** - Flight review currency
- **FAR 61.57(a)** - Passenger currency (takeoffs/landings)
- **FAR 61.57(b)** - Night passenger currency
- **FAR 61.57(c)** - IFR currency
- **FAR 61.57(f)** - NVG currency
- **FAR 61.58** - Proficiency checks for type-rated aircraft
- **FAR 61.195(a)** - CFI daily instruction limits
- **FAR 61.195(f)** - CFI time-in-type requirements

![Architecture diagram showing the relationship between Reader, Validator, and data models](architecture)

## Topics

### Command-Line Tool

- <doc:UsingTheCLI>

### Library Integration

- <doc:GettingStarted>
- <doc:ReadingLogTenData>
- <doc:ValidatingFlights>
- <doc:UnderstandingViolations>
