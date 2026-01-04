/// Checks for NVG (Night Vision Goggle) flights without required currency per FAR 61.57(f).
///
/// To act as pilot in command using NVGs, the pilot must have completed within the
/// preceding 4 calendar months either:
/// - 3 NVG takeoffs and 3 NVG landings, OR
/// - An NVG proficiency check (FAR 61.31(k))
///
/// The takeoffs/landings must be in the same aircraft category.
final class NoNVGCurrency: ViolationChecker {
  let flightIndex: FlightIndex

  required init(flightIndex: FlightIndex) {
    self.flightIndex = flightIndex
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if flight.takeoffsNVG == 0 || flight.landingsNVG == 0 { return nil }

    let eligibleFlights = flights(
      within: .calendarMonths(4),
      of: flight,
      matching: .none(for: flight)
    )
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
