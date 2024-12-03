final class NoPassengerCurrency: ViolationChecker {
    let flights: Array<Flight>
    
    required init(flights: Array<Flight>) {
        self.flights = flights
    }
    
    func check(flight: Flight) async throws -> Violation? {
        if flight.isDualReceived || !flight.isPIC { return nil }
        if !flight.hasPassengers { return nil }
        
        let eligibleFlights = try await flightsWithinLast(days: 90, ofFlight: flight, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true),
            totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.totalTakeoffs },
            totalLandings = eligibleFlights.reduce(0) { $0 + $1.totalLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return .noPassengerCurrency }
        
        if flight.isTailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.isTailwheel },
                tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.totalTakeoffs },
                tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.fullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return .noPassengerCurrency }
        }
        
        return nil
    }
}
