final class NoFlightReview: ViolationChecker {
    let flights: Array<Flight>
    
    required init(flights: Array<Flight>) {
        self.flights = flights
    }
    
    func check(flight: Flight) async throws -> Violation? {
        if flight.isDualReceived || !flight.isPIC { return nil }
        if flight.isStudentSolo || flight.isFlightReview || flight.isCheckride { return nil }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 24, ofFlight: flight)
        return eligibleFlights.first { $0.isFlightReview || $0.isCheckride } == nil ? .noFlightReview : nil
    }
}
