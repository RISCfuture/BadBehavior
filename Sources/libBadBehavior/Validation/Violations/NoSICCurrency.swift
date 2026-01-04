/// Checks for SIC operations without required currency per FAR 61.55(b).
///
/// To act as SIC in an aircraft requiring a type rating, the pilot must have made
/// at least 3 takeoffs and landings as the sole manipulator of the flight controls
/// within the preceding 90 days in the same type of aircraft.
///
/// ## Applicability
///
/// This rule only applies when:
/// - The aircraft requires a type rating
/// - No passengers are aboard (FAR 61.55(b) allows non-current SIC for ferry flights)
///
/// - Note: This check does not apply to ferry flights or test flights which are exempt
///   from the currency requirement. A future enhancement could add a custom field to
///   identify such flights.
///
/// - TODO: Add ferry/test flight exclusion when custom field is available
final class NoSICCurrency: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    guard let aircraft = flight.aircraft else { return nil }

    // Only applies to SIC flights in type-rated aircraft
    if !flight.isSIC { return nil }
    if !aircraft.typeRatingRequired { return nil }

    // Does not apply when passengers are aboard (only for ferry/positioning flights)
    if flight.hasPassengers { return nil }

    // Check for 3 takeoffs and landings in the same type within 90 days
    let eligibleFlights = try flightsWithinLast(
      calendarDays: 90,
      ofFlight: flight,
      matchingCategory: true,
      matchingClass: true,
      matchingTypeIfRequired: true
    )

    let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.totalTakeoffs }
    let totalLandings = eligibleFlights.reduce(0) { $0 + $1.totalLandings }

    return (totalTakeoffs < 3 || totalLandings < 3) ? .noSICCurrency : nil
  }
}
