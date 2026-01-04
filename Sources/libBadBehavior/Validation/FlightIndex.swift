import Foundation

/// Provides O(log N) flight lookups using binary search on chronologically sorted flights.
///
/// `FlightIndex` wraps a sorted array of flights and provides efficient date-range
/// queries. Instead of scanning the entire flight list (O(N)), it uses binary search
/// to find the relevant date range (O(log N)) and then filters only those flights.
///
/// ## Usage
///
/// ```swift
/// let index = FlightIndex(flights: sortedFlights)
///
/// // Find flights in the last 90 days
/// let recent = index.flights(
///     within: .calendarDays(90),
///     of: referenceFlight,
///     matching: .full(for: referenceFlight)
/// )
/// ```
///
/// ## Performance
///
/// For a logbook with N flights where K flights fall within the query window:
/// - Date range lookup: O(log N)
/// - Criteria filtering: O(K)
/// - Total: O(log N + K) vs O(N) for linear scan
struct FlightIndex: Sendable {
  /// All flights in chronological order.
  let flights: [Flight]

  /// Returns the index of the first flight on or after the given date.
  ///
  /// Uses binary search for O(log N) lookup.
  ///
  /// - Parameter targetDate: The date to search for.
  /// - Returns: The index of the first flight with `date >= targetDate`,
  ///   or `flights.count` if no such flight exists.
  func lowerBound(for targetDate: Date) -> Int {
    var low = 0
    var high = flights.count

    while low < high {
      let mid = low + (high - low) / 2
      if flights[mid].date < targetDate {
        low = mid + 1
      } else {
        high = mid
      }
    }
    return low
  }

  /// Returns the index of the first flight after the given date.
  ///
  /// Uses binary search for O(log N) lookup.
  ///
  /// - Parameter targetDate: The date to search for.
  /// - Returns: The index of the first flight with `date > targetDate`,
  ///   or `flights.count` if no such flight exists.
  func upperBound(for targetDate: Date) -> Int {
    var low = 0
    var high = flights.count

    while low < high {
      let mid = low + (high - low) / 2
      if flights[mid].date <= targetDate {
        low = mid + 1
      } else {
        high = mid
      }
    }
    return low
  }

  /// Returns flights within a time window matching the given criteria.
  ///
  /// This is the primary query method. It uses binary search to find the date range,
  /// then filters by the matching criteria.
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
    let startDate = window.startDate(from: flight.date)
    return self.flights(
      from: startDate,
      to: flight.date,
      excluding: flight,
      matching: criteria
    )
  }

  /// Returns flights in a date range matching the given criteria.
  ///
  /// - Parameters:
  ///   - startDate: The start of the date range (inclusive).
  ///   - endDate: The end of the date range (inclusive).
  ///   - excludedFlight: A flight to exclude from results (typically the reference flight).
  ///   - criteria: Aircraft matching criteria.
  /// - Returns: Flights in the range that match the criteria.
  func flights(
    from startDate: Date,
    to endDate: Date,
    excluding excludedFlight: Flight,
    matching criteria: FlightMatchCriteria
  ) -> [Flight] {
    let startIndex = lowerBound(for: startDate)
    let endIndex = upperBound(for: endDate)

    // Early exit if no flights in range
    guard startIndex < endIndex else { return [] }

    // Filter only the relevant slice
    return flights[startIndex..<endIndex].filter { candidate in
      candidate != excludedFlight && criteria.matches(candidate)
    }
  }

  /// Returns all flights before the given flight.
  ///
  /// Useful for calculating total time accumulated before a flight.
  ///
  /// - Parameter flight: The reference flight.
  /// - Returns: All flights with dates before the reference flight's date.
  func flights(before flight: Flight) -> [Flight] {
    let endIndex = lowerBound(for: flight.date)
    guard endIndex > 0 else { return [] }
    return Array(flights[0..<endIndex])
  }

  /// Returns flights within a time window, including the reference flight if it matches.
  ///
  /// Unlike `flights(within:of:matching:)`, this method does not exclude the
  /// reference flight. Useful for queries where the reference flight should be
  /// considered (e.g., calculating totals that include the current flight).
  ///
  /// - Parameters:
  ///   - window: The time window to look back.
  ///   - flight: The reference flight for the time window.
  ///   - criteria: Aircraft matching criteria.
  /// - Returns: All flights in the window matching criteria, including the reference.
  func flightsIncludingSelf(
    within window: TimeWindow,
    of flight: Flight,
    matching criteria: FlightMatchCriteria
  ) -> [Flight] {
    let startDate = window.startDate(from: flight.date)
    let startIndex = lowerBound(for: startDate)
    let endIndex = upperBound(for: flight.date)

    guard startIndex < endIndex else { return [] }

    return flights[startIndex..<endIndex].filter { candidate in
      criteria.matches(candidate)
    }
  }
}
