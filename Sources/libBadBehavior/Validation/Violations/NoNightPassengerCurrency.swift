/// Checks for night flights with passengers without required currency per FAR 61.57(b).
///
/// To carry passengers at night, the pilot must have made at least 3 takeoffs and
/// 3 full-stop landings at night within the preceding 90 days in the same category,
/// class, and (if type-rated) type.
///
/// ## Night Definition
///
/// Night is defined as 1 hour after sunset to 1 hour before sunrise per FAR 1.1.
/// For currency purposes, landings must be to a full stop.
///
/// ## Alternate Currency (FAR 61.57(e)(4))
///
/// Pilots meeting certain requirements may use an extended 6-month lookback for night
/// currency in turbine-powered multi-crew aircraft:
/// - 1,500+ hours total time
/// - 15 hours in type within preceding 90 days
/// - 3 night full-stop takeoffs/landings within 6 months
///
/// - TODO: Add Part 142 training program exception when custom field is available
final class NoNightPassengerCurrency: ViolationChecker {
  let flightIndex: FlightIndex

  required init(flightIndex: FlightIndex) {
    self.flightIndex = flightIndex
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.hasPassengers { return nil }
    if !flight.isNight { return nil }

    // First check standard 90-day currency
    let eligibleFlights90 = flights(
      within: .calendarDays(90),
      of: flight,
      matching: .full(for: flight)
    )

    if hasNightCurrency(flights: eligibleFlights90, flight: flight) {
      return nil
    }

    // If standard currency fails, check for alternate currency exception (FAR 61.57(e)(4))
    if qualifiesForAlternateCurrency(flight: flight) {
      let eligibleFlights6mo = flights(
        within: .calendarMonths(6),
        of: flight,
        matching: .full(for: flight)
      )

      if hasNightCurrency(flights: eligibleFlights6mo, flight: flight) {
        return nil
      }
    }

    return .noNightPassengerCurrency
  }

  /// Checks if the given flights provide night currency for the specified flight.
  private func hasNightCurrency(flights eligibleFlights: [Flight], flight: Flight) -> Bool {
    let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.nightTakeoffs }
    let totalLandings = eligibleFlights.reduce(0) { $0 + $1.nightFullStopLandings }

    if totalTakeoffs < 3 || totalLandings < 3 { return false }

    // Tailwheel aircraft require additional check
    if flight.isTailwheel {
      let tailwheelFlights = eligibleFlights.filter(\.isTailwheel)
      let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.nightTakeoffs }
      let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.nightFullStopLandings }
      if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return false }
    }

    return true
  }

  /// Determines if the pilot qualifies for alternate night currency per FAR 61.57(e)(4).
  ///
  /// Requirements:
  /// - Aircraft is turbine-powered and requires a type rating (proxy for multi-crew)
  /// - Pilot has 1,500+ hours total time
  /// - Pilot has 15+ hours in type within preceding 90 days
  private func qualifiesForAlternateCurrency(flight: Flight) -> Bool {
    guard let aircraft = flight.aircraft else { return false }

    // Must be turbine-powered aircraft requiring type rating (heuristic for multi-crew)
    // TODO: Add proper multi-crew field when available
    guard aircraft.typeRatingRequired else { return false }
    guard isTurbinePowered(aircraft) else { return false }

    // Check for 1,500+ hours total time
    let totalTime = totalFlightTime(before: flight)
    guard totalTime >= 1500 else { return false }

    // Check for 15 hours in type within 90 days
    let timeInType = timeInType(for: flight, withinDays: 90)
    guard timeInType >= 15 else { return false }

    return true
  }

  /// Checks if the aircraft is turbine-powered.
  private func isTurbinePowered(_ aircraft: Aircraft) -> Bool {
    switch aircraft.type.engineType {
      case .turboprop, .turbofan, .turbine, .turboshaft, .ramjet, .jet:
        return true
      default:
        return false
    }
  }

  /// Calculates total flight time (PIC + SIC) before the given flight.
  private func totalFlightTime(before flight: Flight) -> Double {
    let priorFlights = flights(before: flight)
    let totalMinutes = priorFlights.reduce(0) { $0 + $1.PICTime + $1.SICTime }
    return Double(totalMinutes) / 60.0
  }

  /// Calculates time in type within the specified number of days before the flight.
  private func timeInType(for flight: Flight, withinDays days: Int) -> Double {
    guard let aircraft = flight.aircraft else { return 0 }

    let eligibleFlights = flights(
      within: .calendarDays(days),
      of: flight,
      matching: .full(for: flight)
    )

    // Only count flights in the exact same type
    let sameTypeFlights = eligibleFlights.filter { f in
      f.aircraft?.type.type == aircraft.type.type
    }

    let totalMinutes = sameTypeFlights.reduce(0) { $0 + $1.PICTime + $1.SICTime }
    return Double(totalMinutes) / 60.0
  }
}
