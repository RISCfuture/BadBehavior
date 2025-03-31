final class DualGiven8In24: ViolationChecker {
    let flights: [Flight]

    required init(flights: [Flight]) {
        self.flights = flights
    }

    func check(flight: Flight) throws -> Violation? {
        if !flight.isDualGiven || !flight.isPIC { return nil }

        let eligibleFlights = try flightsWithinLast(hours: 24, ofFlight: flight),
            dualGivenTime = eligibleFlights.reduce(0) { $0 + $1.dualGivenTime },
            dualGivenHours = Double(dualGivenTime) / 60.0

        return dualGivenHours > 8.0 ? .dualGiven8in24 : nil
    }
}
