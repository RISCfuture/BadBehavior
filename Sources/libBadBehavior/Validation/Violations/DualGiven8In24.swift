final class DualGiven8In24: ViolationChecker {
    let flights: Array<Flight>
    
    required init(flights: Array<Flight>) {
        self.flights = flights
    }
    
    func check(flight: Flight) async throws -> Violation? {
        if !flight.isDualGiven || !flight.isPIC { return nil }
        
        let eligibleFlights = try await flightsWithinLast(hours: 24, ofFlight: flight),
            dualGivenTime = eligibleFlights.reduce(0) { $0 + $1.dualGivenTime },
            dualGivenHours = Double(dualGivenTime)/60.0
        
        return dualGivenHours > 8.0 ? .dualGiven8in24 : nil
    }
}
