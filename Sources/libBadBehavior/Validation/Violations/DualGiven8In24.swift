/// Checks for CFI flights exceeding 8 hours of dual given in 24 hours per FAR 61.195(a).
///
/// A flight instructor may not conduct more than 8 hours of flight training in any
/// 24-consecutive-hour period. This checker sums all dual given time from the current
/// flight and all flights within the preceding 24 hours.
final class DualGiven8In24: ViolationChecker {
  let flightIndex: FlightIndex

  required init(flightIndex: FlightIndex) {
    self.flightIndex = flightIndex
  }

  func check(flight: Flight) throws -> Violation? {
    if !flight.isDualGiven || !flight.isPIC { return nil }

    let eligibleFlights = flights(
      within: .hours(24),
      of: flight,
      matching: .none(for: flight)
    )
    let dualGivenTime = eligibleFlights.reduce(0) { $0 + $1.dualGivenTime }
    let dualGivenHours = Double(dualGivenTime) / 60.0

    return dualGivenHours > 8.0 ? .dualGiven8in24 : nil
  }
}
