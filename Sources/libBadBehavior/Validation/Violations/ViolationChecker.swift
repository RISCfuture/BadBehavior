import Foundation

/// A protocol for types that check flights for specific FAR violations.
///
/// Each `ViolationChecker` implementation is responsible for detecting a single type
/// of violation. Checkers have access to the complete flight history via a
/// `FlightIndex` for efficient date-range queries.
///
/// ## Implementation Notes
///
/// - Checkers must be `Sendable` for use with Swift Concurrency.
/// - The ``setup()`` method is called once before checking any flights, allowing
///   expensive pre-computation to be done upfront.
/// - The ``check(flight:)`` method should return `nil` if no violation is detected,
///   or the appropriate ``Violation`` case if one is found.
protocol ViolationChecker: Sendable {
  /// Index providing efficient flight lookups.
  var flightIndex: FlightIndex { get }

  /// Creates a checker with the given flight index.
  ///
  /// - Parameter flightIndex: Index of all flights in the logbook.
  init(flightIndex: FlightIndex)

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
  /// All flights in chronological order.
  ///
  /// Convenience accessor for checkers that need to iterate all flights.
  var flights: [Flight] {
    flightIndex.flights
  }

  /// Default implementation that does nothing.
  func setup() throws {}

  /// Returns flights within a time window matching the given criteria.
  ///
  /// This is the primary query method for currency checks. It uses binary search
  /// to efficiently find flights in the date range.
  ///
  /// - Parameters:
  ///   - window: The time window to look back from the reference flight.
  ///   - flight: The reference flight (typically the one being checked).
  ///   - criteria: Aircraft matching criteria (category, class, type).
  /// - Returns: Flights within the window that match the criteria.
  func flights(
    within window: TimeWindow,
    of flight: Flight,
    matching criteria: FlightMatchCriteria
  ) -> [Flight] {
    flightIndex.flights(within: window, of: flight, matching: criteria)
  }

  /// Returns all flights before the given flight.
  ///
  /// Useful for calculating total time accumulated before a flight.
  ///
  /// - Parameter flight: The reference flight.
  /// - Returns: All flights with dates before the reference flight's date.
  func flights(before flight: Flight) -> [Flight] {
    flightIndex.flights(before: flight)
  }
}
