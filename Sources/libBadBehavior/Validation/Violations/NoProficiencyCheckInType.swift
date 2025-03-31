final class NoProficiencyCheckInType: ViolationChecker {
    let flights: [Flight]

    required init(flights: [Flight]) {
        self.flights = flights
    }

    func check(flight: Flight) throws -> Violation? {
        guard let aircraft = flight.aircraft else { return nil }

        if flight.isDualReceived || flight.isRecurrent { return nil }
        if !aircraft.typeRatingRequired { return nil }

        let eligibleFlights = try flightsWithinLast(calendarMonths: 24, ofFlight: flight, matchingTypeIfRequired: true)
        return eligibleFlights.contains(where: \.isRecurrent) ? nil : .noPPCInType
    }
}
