/// Checks for flights in type-rated aircraft without a proficiency check in type per FAR 61.58(a)(2).
///
/// In addition to the 24-month general proficiency check requirement, pilots must also
/// complete a proficiency check in the same type of aircraft (or an approved simulator)
/// within the preceding 12 calendar months.
final class NoProficiencyCheckInType: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    guard let aircraft = flight.aircraft else { return nil }

    if flight.isDualReceived || flight.isRecurrent { return nil }
    if !aircraft.typeRatingRequired { return nil }

    let eligibleFlights = try flightsWithinLast(
      calendarMonths: 24,
      ofFlight: flight,
      matchingTypeIfRequired: true
    )
    return eligibleFlights.contains(where: \.isRecurrent) ? nil : .noPPCInType
  }
}
