/// Checks for flights in type-rated aircraft without a proficiency check per FAR 61.58(a)(1).
///
/// Pilots of aircraft requiring a type rating must complete a proficiency check
/// within the preceding 24 calendar months. This applies to:
/// - Turbine-powered aircraft
/// - Powered-lift aircraft
/// - Aircraft with maximum gross weight of 12,500 pounds or more
final class NoProficiencyCheck: ViolationChecker {
  let flightIndex: FlightIndex

  required init(flightIndex: FlightIndex) {
    self.flightIndex = flightIndex
  }

  func check(flight: Flight) throws -> Violation? {
    guard let aircraft = flight.aircraft else { return nil }

    if flight.isDualReceived || flight.isRecurrent { return nil }
    if !aircraft.typeRatingRequired { return nil }

    let eligibleFlights = flights(
      within: .calendarMonths(12),
      of: flight,
      matching: .none(for: flight)
    )
    return eligibleFlights.contains(where: \.isRecurrent) ? nil : .noPPC
  }
}
