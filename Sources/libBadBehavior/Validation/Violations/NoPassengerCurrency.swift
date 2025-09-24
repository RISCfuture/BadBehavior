final class NoPassengerCurrency: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.hasPassengers { return nil }

    let eligibleFlights = try flightsWithinLast(
      calendarDays: 90,
      ofFlight: flight,
      matchingCategory: true,
      matchingClass: true,
      matchingTypeIfRequired: true
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
