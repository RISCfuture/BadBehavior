/// Checks for CFI flights without required time in type per FAR 61.195(f).
///
/// To give training in a multiengine airplane, helicopter, or powered-lift aircraft,
/// the flight instructor must have at least 5 flight hours as pilot in command in
/// the specific make and model of aircraft.
///
/// This rule applies to:
/// - Multiengine land and sea airplanes
/// - Rotorcraft (helicopters and gyroplanes)
/// - Powered-lift aircraft
final class DualGivenTimeInType: ViolationChecker {
  let flights: [Flight]

  required init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) throws -> Violation? {
    if !flight.isDualGiven || !flight.isPIC { return nil }
    guard let aircraft = flight.aircraft else { return nil }

    switch aircraft.type.category {
      case .airplane:
        switch aircraft.type.class {
          case .multiEngineLand, .multiEngineSea: break
          default: return nil
        }
      case .rotorcraft, .poweredLift: break
      default: return nil
    }

    let eligibleFlights = flights.filter { checkFlight in
      guard let checkAircraft = checkFlight.aircraft else { return false }
      return checkAircraft.type.type == aircraft.type.type
    }
    let timeInType = eligibleFlights.reduce(0) { $0 + $1.PICTime }

    return timeInType < 5 * 60 ? .dualGivenTimeInType : nil
  }
}
