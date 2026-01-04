import Foundation

/// Checks for IFR flights without required instrument currency per FAR 61.57(c).
///
/// To act as pilot in command under IFR, the pilot must have completed within the
/// preceding 6 calendar months:
/// - 6 instrument approaches
/// - Holding procedures
/// - Intercepting and tracking courses (assumed if approaches/holds were flown)
///
/// ## Grace Period
///
/// If instrument currency lapses, there is a 6-month grace period during which
/// approaches and holds can restore currency. However, if 12 months pass without
/// the required experience, an IPC (Instrument Proficiency Check) is required.
///
/// ## Implementation Notes
///
/// This checker uses an actor model with pre-computed currency data because
/// determining whether a flight counts toward currency requires recursive
/// lookback through flight history.
actor NoIFRCurrency: ViolationChecker {
  let flightIndex: FlightIndex

  private var countsForIFRCurrency = [URL: Bool]()

  init(flightIndex: FlightIndex) {
    self.flightIndex = flightIndex
  }

  func check(flight: Flight) throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.isIFR || flight.safetyPilotOnboard || flight.isIPC { return nil }

    let candidateFlights = flights(
      within: .calendarMonths(6),
      of: flight,
      matching: .category(for: flight)
    ).filter { f in
      f.hasApproaches || f.hasHolds || f.isIPC
    }

    // Filter to flights within grace period
    let eligibleFlights = candidateFlights.filter { isWithinGracePeriod($0) }

    // check for IPC first
    if eligibleFlights.contains(where: \.isIPC) { return nil }

    // verify that there were 6a/1h within past 6mo
    let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount }
    let hold = eligibleFlights.contains(where: \.hasHolds)

    return (totalApproaches < 6 || !hold) ? .noIFRCurrency : nil
  }

  func setup() throws {
    // Pre-compute grace period status for all flights
    for flight in flights {
      if flight.isIPC {
        countsForIFRCurrency[flight.id] = true
        continue
      }
      if !flight.hasApproaches && !flight.hasHolds {
        countsForIFRCurrency[flight.id] = false
        // Note: Don't continue - still need to check 12mo lookback
      }

      let eligibleFlights = flights(
        within: .calendarMonths(12),
        of: flight,
        matching: .category(for: flight)
      )

      if eligibleFlights.contains(where: \.isIPC) {
        countsForIFRCurrency[flight.id] = true
        continue
      }

      let countingFlights = eligibleFlights.filter { flightCountsForIFRCurrency($0) }
      let totalApproaches = countingFlights.reduce(0) { $0 + $1.approachCount }
      let totalHolds = countingFlights.reduce(0 as UInt) { $0 + $1.holds }

      countsForIFRCurrency[flight.id] = (totalApproaches >= 6 && totalHolds >= 1)
    }
  }

  // MARK: - Private

  /// Checks if a flight was done while the pilot was within the IFR grace period.
  ///
  /// Flights with practice approaches don't count towards currency unless they
  /// are within 12 months of preceding practice approaches or IPC.
  private func isWithinGracePeriod(_ flight: Flight) -> Bool {
    if let counts = countsForIFRCurrency[flight.id] {
      return counts
    }

    // Fallback for flights not pre-computed (shouldn't happen in normal use)
    let eligibleFlights = flights(
      within: .calendarMonths(12),
      of: flight,
      matching: .category(for: flight)
    ).filter { f in
      (f.hasApproaches || f.hasHolds || f.isIPC) && isWithinGracePeriod(f)
    }

    if eligibleFlights.contains(where: \.isIPC) { return true }

    let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount }
    let hold = eligibleFlights.contains(where: \.hasHolds)

    let counts = totalApproaches >= 6 && hold
    countsForIFRCurrency[flight.id] = counts
    return counts
  }

  private func flightCountsForIFRCurrency(_ flight: Flight) -> Bool {
    return countsForIFRCurrency[flight.id] ?? false
  }
}
