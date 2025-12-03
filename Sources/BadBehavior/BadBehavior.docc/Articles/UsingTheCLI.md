# Using the BadBehavior CLI

Learn how to run BadBehavior and interpret its output.

## Overview

BadBehavior scans your LogTen Pro logbook and reports potential regulatory violations.

## Installation

Build the tool using Swift Package Manager:

```bash
cd BadBehavior
swift build -c release
```

The binary will be located at `.build/release/BadBehavior`.

## Running BadBehavior

### Default Usage

Run without arguments to scan your default LogTen Pro installation:

```bash
BadBehavior
```

### Custom Paths

Specify custom file locations if your LogTen Pro data is in a non-standard location:

```bash
BadBehavior \
  --logten-file /path/to/LogTenCoreDataStore.sql \
  --logten-managed-object-model /path/to/CNLogBookDocument.momd
```

## Command-Line Options

| Option | Description |
|--------|-------------|
| `--logten-file` | Path to the LogTenCoreDataStore.sql file |
| `--logten-managed-object-model` | Path to the LogTen Pro managed object model directory |
| `--help` | Show help information |

## Output Format

BadBehavior outputs violations grouped by flight:

```
Processing...
5 violations total.

12/25/23 N12345 KSFO -> KLAX
Christmas flight

- Flight review not accomplished within prior 24 calendar months [61.56(c)]
- Carried passengers without having completed required takeoffs and landings [61.57(a)]


01/15/24 N12345 KLAX -> KLAS

- Flew under IFR without having completed required approaches/holds or IPC [61.57(c)]
```

Each violation includes the FAR section reference in brackets.

## LogTen Pro Requirements

BadBehavior requires specific custom fields to be configured in LogTen Pro:

### Flight Custom Fields
- **Night Full Stops** (Custom Landings) - For tracking night currency
- **FAR 61.58** (Custom Notes) - For marking proficiency check flights
- **Checkride** (Custom Notes) - For marking checkride flights
- **FAR 61.31(k)** (Custom Notes) - For NVG proficiency checks

### Flight Crew Custom Roles
- **Safety Pilot** (Custom Role)
- **Examiner** (Custom Role)

### Aircraft Type Custom Fields
- **Type Code** - FAA type designator
- **Sim Type** - BATD, AATD, FTD, or FFS
- **Sim A/C Cat** - ASEL, ASES, AMEL, AMES, or GL

For detailed configuration instructions, see the [README](https://github.com/RISCfuture/BadBehavior#assumptions-and-idiosyncrasies).

## Violations Detected

BadBehavior checks for:

- **FAR 61.56(c)** - Flight review currency (24 months)
- **FAR 61.57(a)** - Passenger currency (90 days)
- **FAR 61.57(b)** - Night passenger currency (90 days)
- **FAR 61.57(c)** - IFR currency (6 months + grace period)
- **FAR 61.57(f)** - NVG currency
- **FAR 61.58** - Type rating proficiency checks
- **FAR 61.195(a)** - CFI 8-hour daily limit
- **FAR 61.195(f)** - CFI time-in-type requirements
