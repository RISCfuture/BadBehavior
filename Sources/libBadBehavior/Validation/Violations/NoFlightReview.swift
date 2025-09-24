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
