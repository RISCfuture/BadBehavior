/// Checks for flights made without a valid flight review per FAR 61.56(c).
///
/// A pilot may not act as pilot in command unless they have accomplished a flight review
/// within the preceding 24 calendar months. A checkride satisfies the flight review requirement.
///
/// ## Exemptions
///
/// This checker does not flag flights that are:
/// - Dual instruction received (the instructor is PIC)
/// - Student pilot solo flights
/// - The flight review itself
/// - A checkride (practical test)
final class NoFlightReview: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if flight.isStudentSolo || flight.isFlightReview || flight.isCheckride { return nil }

    let eligibleFlights = try flightsWithinLast(calendarMonths: 24, ofFlight: flight)
    return eligibleFlights.contains { $0.isFlightReview || $0.isCheckride } ? nil : .noFlightReview
  }
}
