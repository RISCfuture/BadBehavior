/// Checks for night flights with passengers without required currency per FAR 61.57(b).
///
/// To carry passengers at night, the pilot must have made at least 3 takeoffs and
/// 3 full-stop landings at night within the preceding 90 days in the same category,
/// class, and (if type-rated) type.
///
/// ## Night Definition
///
/// Night is defined as 1 hour after sunset to 1 hour before sunrise per FAR 1.1.
/// For currency purposes, landings must be to a full stop.
final class NoNightPassengerCurrency: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.hasPassengers { return nil }
    if !flight.isNight { return nil }

    let eligibleFlights = try flightsWithinLast(
      calendarDays: 90,
      ofFlight: flight,
      matchingCategory: true,
      matchingClass: true,
      matchingTypeIfRequired: true
    )
    let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.nightTakeoffs }
    let totalLandings = eligibleFlights.reduce(0) { $0 + $1.nightFullStopLandings }
    if totalTakeoffs < 3 || totalLandings < 3 { return .noNightPassengerCurrency }

    if flight.isTailwheel {
      let tailwheelFlights = eligibleFlights.filter(\.isTailwheel)
      let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.nightTakeoffs }
      let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.nightFullStopLandings }
      if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return .noNightPassengerCurrency }
    }

    return nil
  }
}
