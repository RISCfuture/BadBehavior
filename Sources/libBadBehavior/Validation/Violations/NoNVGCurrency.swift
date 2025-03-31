final class NoNVGCurrency: ViolationChecker {
    let flights: [Flight]

    required init(flights: [Flight]) {
        self.flights = flights
    }

    func check(flight: Flight) throws -> Violation? {
        if flight.isDualReceived || !flight.isPIC { return nil }
        if flight.takeoffsNVG == 0 || flight.landingsNVG == 0 { return nil }

        let eligibleFlights = try flightsWithinLast(calendarMonths: 4, ofFlight: flight),
            totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.takeoffsNVG },
            totalLandings = eligibleFlights.reduce(0) { $0 + $1.landingsNVG },
            hasProficiencyCheck = eligibleFlights.contains(where: { isNVGProficiencyCheck(flight: flight, checkFlight: $0) })
        if totalTakeoffs < 3 || totalLandings < 3 && !hasProficiencyCheck { return .noNVGCurrency }

        return nil
    }

    private func isNVGProficiencyCheck(flight: Flight, checkFlight: Flight) -> Bool {
        guard let aircraft = flight.aircraft,
              let checkAircraft = checkFlight.aircraft else { return false }
        guard checkFlight.isNVGProficiencyCheck else { return false }
        let category = aircraft.type.category == .simulator ? aircraft.type.simCategory : aircraft.type.category,
            checkCategory = checkAircraft.type.category == .simulator ? checkAircraft.type.simCategory : checkAircraft.type.category
        return category == checkCategory
    }
}
