# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Require Swift 6.4 and macOS 27.
- Adopt strict memory safety.
- Build, test, and release on the Xcode 27 runner image.

## [1.0.0] - 2026-09-15

### Added

- `BadBehavior`, a command-line tool that scans a LogTen for Mac logbook and
  reports flights that may have been flown contrary to FAR Part 61 and 91
  requirements, along with the reason each flight was flagged.
- Flight review checks: flights made outside the 24-month window following a
  BFR.
- Passenger currency checks: day and night takeoffs and landings within the
  preceding 90 days, including the special tailwheel requirements, plus the NVG
  equivalents.
- Instrument currency checks: IFR flights made with fewer than six approaches
  and one hold in the preceding six months and no IPC.
- Type-rating checks: flights in type-rated aircraft without the required FAR
  61.58 proficiency check (both in general and in type), and SIC operations
  without the FAR 61.55(b) takeoff and landing currency.
- Flight instructor checks: the FAR 61.195(a) eight-hours-in-24 training limit,
  and the FAR 61.195(f) five hours of PIC time in make and model required to
  instruct in multiengine airplanes, rotorcraft, and powered-lift aircraft.
- Text output (the default) and JSON output via `--format`, with the logbook
  located automatically or specified with `--logten-file` and
  `--logten-managed-object-model`.

[Unreleased]: https://github.com/RISCfuture/BadBehavior/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/RISCfuture/BadBehavior/releases/tag/v1.0.0
