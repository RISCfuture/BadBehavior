final class NoProficiencyCheck: ViolationChecker {
    let flights: Array<Flight>
    
    required init(flights: Array<Flight>) {
        self.flights = flights
    }
    
    func check(flight: Flight) async throws -> Violation? {
        guard let aircraft = flight.aircraft else { return nil }
        
        if flight.isDualReceived   || flight.isRecurrent { return nil }
        if !aircraft.typeRatingRequired { return nil }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 12, ofFlight: flight)
        return eligibleFlights.first { $0.isRecurrent } == nil ? .noPPC : nil
    }
}
