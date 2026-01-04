/// Checks for flights carrying passengers without required currency per FAR 61.57(a).
///
/// To carry passengers, the pilot must have made at least 3 takeoffs and 3 landings
/// within the preceding 90 days in the same category, class, and (if type-rated) type.
///
/// ## Tailwheel Requirements
///
/// For tailwheel aircraft, the landings must be to a full stop (FAR 61.57(a)(1)(ii)).
final class NoPassengerCurrency: ViolationChecker {
  let flightIndex: FlightIndex

  required init(flightIndex: FlightIndex) {
    self.flightIndex = flightIndex
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.hasPassengers { return nil }

    let eligibleFlights = flights(
      within: .calendarDays(90),
      of: flight,
      matching: .full(for: flight)
    )
    let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.totalTakeoffs }
    let totalLandings = eligibleFlights.reduce(0) { $0 + $1.totalLandings }
    if totalTakeoffs < 3 || totalLandings < 3 { return .noPassengerCurrency }

    if flight.isTailwheel {
      let tailwheelFlights = eligibleFlights.filter(\.isTailwheel)
      let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.totalTakeoffs }
      let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.fullStopLandings }
      if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return .noPassengerCurrency }
    }

    return nil
  }
}
