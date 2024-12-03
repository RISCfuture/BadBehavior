final class NoNightPassengerCurrency: ViolationChecker {
    let flights: Array<Flight>
    
    required init(flights: Array<Flight>) {
        self.flights = flights
    }
    
    func check(flight: Flight) async throws -> Violation? {
        if flight.isDualReceived || !flight.isPIC { return nil }
        if !flight.hasPassengers { return nil }
        if !flight.isNight { return nil }
        
        let eligibleFlights = try await flightsWithinLast(days: 90, ofFlight: flight, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true)
        let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.nightTakeoffs }
        let totalLandings = eligibleFlights.reduce(0) { $0 + $1.nightFullStopLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return .noNightPassengerCurrency }
        
        if flight.isTailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.isTailwheel }
            let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.nightTakeoffs }
            let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.nightFullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return .noNightPassengerCurrency }
        }
        
        return nil
    }
}
