/// Checks for NVG flights with passengers without required currency per FAR 61.57(f).
///
/// To carry passengers while using NVGs, the pilot must have completed within the
/// preceding 2 calendar months either:
/// - 3 NVG takeoffs and 3 NVG landings, OR
/// - An NVG proficiency check (FAR 61.31(k))
///
/// This is a stricter requirement than solo NVG flight (which allows 4 months).
final class NoNVGPassengerCurrency: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.hasPassengers { return nil }
    if flight.takeoffsNVG == 0 || flight.landingsNVG == 0 { return nil }

    let eligibleFlights = try flightsWithinLast(calendarMonths: 2, ofFlight: flight)
    let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.takeoffsNVG }
    let totalLandings = eligibleFlights.reduce(0) { $0 + $1.landingsNVG }
    let hasProficiencyCheck = eligibleFlights.contains(where: {
      isNVGProficiencyCheck(flight: flight, checkFlight: $0)
    })
    if totalTakeoffs < 3 || totalLandings < 3 && !hasProficiencyCheck { return .noNVGCurrency }

    return nil
  }

  private func isNVGProficiencyCheck(flight: Flight, checkFlight: Flight) -> Bool {
    guard let aircraft = flight.aircraft,
      let checkAircraft = checkFlight.aircraft
    else { return false }
    guard checkFlight.isNVGProficiencyCheck else { return false }
    let category =
      aircraft.type.category == .simulator ? aircraft.type.simCategory : aircraft.type.category
    let checkCategory =
      checkAircraft.type.category == .simulator
      ? checkAircraft.type.simCategory : checkAircraft.type.category
    return category == checkCategory
  }
}
