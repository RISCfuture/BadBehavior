import Foundation

/// A protocol for types that check flights for specific FAR violations.
///
/// Each `ViolationChecker` implementation is responsible for detecting a single type
/// of violation. Checkers have access to the complete flight history to properly
/// evaluate currency requirements.
///
/// ## Implementation Notes
///
/// - Checkers must be `Sendable` for use with Swift Concurrency.
/// - The ``setup()`` method is called once before checking any flights, allowing
///   expensive pre-computation to be done upfront.
/// - The ``check(flight:)`` method should return `nil` if no violation is detected,
///   or the appropriate ``Violation`` case if one is found.
protocol ViolationChecker: Sendable {
  /// All flights in the logbook, used to check currency history.
  var flights: [Flight] { get }

  /// Creates a checker with the given flight history.
  ///
  /// - Parameter flights: All flights in the logbook.
  init(flights: [Flight])

  /// Checks a single flight for violations.
  ///
  /// - Parameter flight: The flight to check.
  /// - Returns: A ``Violation`` if one is detected, or `nil` if the flight is compliant.
  func check(flight: Flight) async throws -> Violation?

  /// Performs any expensive setup before checking flights.
  ///
  /// This method is called once after initialization, before any calls to ``check(flight:)``.
  /// Use this for pre-computing data that will be needed across multiple flight checks.
  func setup() async throws
}

extension ViolationChecker {
  /// Default implementation that does nothing.
  func setup() throws {}

  /// Returns flights within a specified number of hours before the given flight.
  ///
  /// - Parameters:
  ///   - hours: The number of hours to look back.
  ///   - flight: The reference flight.
  ///   - matchingCategory: If `true`, only include flights in the same aircraft category.
  ///   - matchingClass: If `true`, only include flights in the same aircraft class.
  ///   - matchingTypeIfRequired: If `true` and the aircraft requires a type rating,
  ///     only include flights in the same aircraft type.
  /// - Returns: Flights within the time window that match the specified criteria.
  func flightsWithinLast(
    hours: Int,
    ofFlight flight: Flight,
    matchingCategory: Bool = false,
    matchingClass: Bool = false,
    matchingTypeIfRequired: Bool = false
  ) throws -> [Flight] {
    guard let aircraft = flight.aircraft else { return [] }

    let referenceDate = Calendar.current.date(byAdding: .hour, value: -hours, to: flight.date)!

    return try flights.filter { f in
      let differentFlight = f != flight
      let withinDateRange = (referenceDate...flight.date).contains(f.date)
      let matchesCategory =
        try (!matchingCategory || self.matchesCategory(current: flight, past: f))
      let matchesClass = try (!matchingClass || self.matchesClass(current: flight, past: f))
      let matchesType =
        try
        (!matchingTypeIfRequired || !aircraft.typeRatingRequired
        || self.matchesType(current: flight, past: f))

      return differentFlight && withinDateRange && matchesCategory && matchesClass && matchesType
    }
  }

  /// Returns flights within a specified number of calendar days before the given flight.
  ///
  /// Calendar days are calculated from the start of the day (midnight UTC).
  ///
  /// - Parameters:
  ///   - days: The number of calendar days to look back.
  ///   - flight: The reference flight.
  ///   - matchingCategory: If `true`, only include flights in the same aircraft category.
  ///   - matchingClass: If `true`, only include flights in the same aircraft class.
  ///   - matchingTypeIfRequired: If `true` and the aircraft requires a type rating,
  ///     only include flights in the same aircraft type.
  /// - Returns: Flights within the time window that match the specified criteria.
  func flightsWithinLast(
    calendarDays days: Int,
    ofFlight flight: Flight,
    matchingCategory: Bool = false,
    matchingClass: Bool = false,
    matchingTypeIfRequired: Bool = false
  ) throws -> [Flight] {
    guard let aircraft = flight.aircraft else { return [] }

    var referenceDate = Calendar.current.date(byAdding: .day, value: -days, to: flight.date)!
    referenceDate = Calendar.current.date(
      bySettingHour: 0,
      minute: 0,
      second: 0,
      of: referenceDate
    )!

    return try flights.filter { f in
      let differentFlight = f != flight
      let withinDateRange = (referenceDate...flight.date).contains(f.date)
      let matchesCategory =
        try (!matchingCategory || self.matchesCategory(current: flight, past: f))
      let matchesClass = try (!matchingClass || self.matchesClass(current: flight, past: f))
      let matchesType =
        try
        (!matchingTypeIfRequired || !aircraft.typeRatingRequired
        || self.matchesType(current: flight, past: f))

      return differentFlight && withinDateRange && matchesCategory && matchesClass && matchesType
    }
  }

  /// Returns flights within a specified number of calendar months before the given flight.
  ///
  /// Calendar months are calculated from the first day of the month. For example, if the
  /// reference flight is on March 15 and `months` is 6, flights from September 1 through
  /// March 15 are included.
  ///
  /// - Parameters:
  ///   - months: The number of calendar months to look back.
  ///   - flight: The reference flight.
  ///   - matchingCategory: If `true`, only include flights in the same aircraft category.
  ///   - matchingClass: If `true`, only include flights in the same aircraft class.
  ///   - matchingTypeIfRequired: If `true` and the aircraft requires a type rating,
  ///     only include flights in the same aircraft type.
  /// - Returns: Flights within the time window that match the specified criteria.
  func flightsWithinLast(
    calendarMonths months: Int,
    ofFlight flight: Flight,
    matchingCategory: Bool = false,
    matchingClass: Bool = false,
    matchingTypeIfRequired: Bool = false
  ) throws -> [Flight] {
    guard let aircraft = flight.aircraft else { return [] }

    var referenceDate = Calendar.current.date(byAdding: .month, value: -months, to: flight.date)!
    var components = Calendar.current.dateComponents([.year, .month, .day], from: referenceDate)
    components.day = 1
    referenceDate = Calendar.current.date(from: components)!

    return try flights.filter { f in
      let differentFlight = f != flight
      let matchesDate = (referenceDate...flight.date).contains(f.date)
      let matchesCategory =
        try (!matchingCategory || self.matchesCategory(current: flight, past: f))
      let matchesClass = try (!matchingClass || self.matchesClass(current: flight, past: f))
      let matchesType =
        try
        (!matchingTypeIfRequired || !aircraft.typeRatingRequired
        || self.matchesType(current: flight, past: f))
      return differentFlight && matchesDate && matchesCategory && matchesClass && matchesType
    }
  }

  /// Checks if two flights are in the same aircraft category.
  ///
  /// Handles simulator logic: FFS (Full Flight Simulator) flights count toward the
  /// simulated aircraft's category.
  ///
  /// - Parameters:
  ///   - current: The flight being checked for violations.
  ///   - past: A historical flight to compare against.
  /// - Returns: `true` if the flights match by category criteria.
  func matchesCategory(current: Flight, past: Flight) throws -> Bool {
    guard let currentAircraft = current.aircraft,
      let pastAircraft = past.aircraft
    else { return false }
    let currentCategory = currentAircraft.type.category
    let pastCategory = pastAircraft.type.category

    if currentCategory == .simulator { return true }
    if currentCategory == pastCategory { return true }
    if pastCategory == .simulator && pastAircraft.type.simType == .FFS {
      return pastAircraft.type.simCategory == currentCategory
    }
    return false
  }

  /// Checks if two flights are in the same aircraft class.
  ///
  /// Handles simulator logic: FFS (Full Flight Simulator) flights count toward the
  /// simulated aircraft's class.
  ///
  /// - Parameters:
  ///   - current: The flight being checked for violations.
  ///   - past: A historical flight to compare against.
  /// - Returns: `true` if the flights match by class criteria.
  func matchesClass(current: Flight, past: Flight) throws -> Bool {
    guard let currentAircraft = current.aircraft,
      let pastAircraft = past.aircraft
    else { return false }
    let currentClass = currentAircraft.type.class
    let pastClass = pastAircraft.type.class
    let pastCategory = pastAircraft.type.category

    if currentClass == pastClass { return true }
    if pastCategory == .simulator && pastAircraft.type.simType == .FFS {
      return pastAircraft.type.simClass == currentClass
    }
    return false
  }

  /// Checks if two flights are in the same aircraft type.
  ///
  /// This is used for type-rating currency checks. Handles simulator logic: FFS
  /// (Full Flight Simulator) flights count toward the simulated aircraft's type.
  ///
  /// - Parameters:
  ///   - current: The flight being checked for violations.
  ///   - past: A historical flight to compare against.
  /// - Returns: `true` if the flights are in the same aircraft type.
  func matchesType(current: Flight, past: Flight) throws -> Bool {
    guard let currentAircraft = current.aircraft,
      let pastAircraft = past.aircraft
    else { return false }

    if currentAircraft.type.type == pastAircraft.type.type { return true }
    if pastAircraft.type.category == .simulator && pastAircraft.type.simType == .FFS {
      return pastAircraft.type.type == currentAircraft.type.type
    }
    return false
  }
}
