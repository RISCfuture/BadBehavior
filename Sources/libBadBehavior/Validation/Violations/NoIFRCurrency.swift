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
  let flights: [Flight]

  private var countsForIFRCurrency = [URL: Bool]()

  init(flights: [Flight]) {
    self.flights = flights
  }

  func check(flight: Flight) async throws -> Violation? {
    if flight.isDualReceived || !flight.isPIC { return nil }
    if !flight.isIFR || flight.safetyPilotOnboard || flight.isIPC { return nil }

    let eligibleFlights = try await withThrowingTaskGroup(
      of: Flight?.self,
      returning: Array<Flight>.self
    ) { group in
      for f in try flightsWithinLast(calendarMonths: 6, ofFlight: flight, matchingCategory: true) {
        group.addTask {
          if !f.hasApproaches && !f.hasHolds && !f.isIPC { return nil }
          return try await self.isWithinGracePeriod(f) ? f : nil
        }
      }

      var flights = [Flight]()
      for try await case let f? in group {
        flights.append(f)
      }
      return flights
    }

    // check for IPC first
    if eligibleFlights.contains(where: \.isIPC) { return nil }

    // verify that there were 6a/1h within past 6mo
    let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount }
    let hold = (eligibleFlights.contains(where: \.hasHolds))
    // you probably intercepted and tracked some radials, right??

    return (totalApproaches < 6 || !hold) ? .noIFRCurrency : nil
  }

  func setup() async throws {
    await withThrowingTaskGroup(of: Void.self) { group in
      for flight in flights {
        group.addTask {
          if flight.isIPC {
            await self.storeIFRCurrency(flight: flight, countsForIFRCurrency: true)
            return
          }
          if !flight.hasApproaches && !flight.hasHolds {
            await self.storeIFRCurrency(flight: flight, countsForIFRCurrency: false)
          }

          let eligibleFlights = try self.flightsWithinLast(
            calendarMonths: 12,
            ofFlight: flight,
            matchingCategory: true
          )
          if eligibleFlights.contains(where: \.isIPC) {
            await self.storeIFRCurrency(flight: flight, countsForIFRCurrency: true)
            return
          }
          var totalApproaches = 0
          var totalHolds: UInt = 0
          for eligibleFlight in eligibleFlights {
            totalApproaches +=
              await
              (self.flightCountsForIFRCurrency(eligibleFlight) ? eligibleFlight.approachCount : 0)
            totalHolds +=
              await (self.flightCountsForIFRCurrency(eligibleFlight) ? eligibleFlight.holds : 0)
          }

          await self.storeIFRCurrency(
            flight: flight,
            countsForIFRCurrency: (totalApproaches >= 6 && totalHolds >= 1)
          )
        }
      }
    }
  }

  // flights with practice approaches don't count towards currency unless they
  // are within 12 months of the preceding practice approaches or IPC
  private func isWithinGracePeriod(_ flight: Flight) async throws -> Bool {
    if let counts = precalculatedFlightCountsForIFRCurrency(flight) { return counts }

    let eligibleFlights = try await withThrowingTaskGroup(
      of: Flight?.self,
      returning: Array<Flight>.self
    ) { group in
      for f in try flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true) {
        group.addTask {
          if !f.hasApproaches && !f.hasHolds && !f.isIPC { return nil }
          return try await self.isWithinGracePeriod(f) ? f : nil
        }
      }

      var flights = [Flight]()
      for try await f in group {
        if let f { flights.append(f) }
      }
      return flights
    }

    // check for IPC first
    if eligibleFlights.contains(where: \.isIPC) { return false }

    let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount }
    let hold = (eligibleFlights.contains(where: \.hasHolds))

    let counts = (totalApproaches < 6 || !hold)
    storeIFRCurrency(flight: flight, countsForIFRCurrency: counts)
    return counts
  }

  private func flightCountsForIFRCurrency(_ flight: Flight) -> Bool {
    return countsForIFRCurrency[flight.id] ?? false
  }

  private func precalculatedFlightCountsForIFRCurrency(_ flight: Flight) -> Bool? {
    return countsForIFRCurrency[flight.id]
  }

  private func storeIFRCurrency(flight: Flight, countsForIFRCurrency counts: Bool) {
    countsForIFRCurrency[flight.id] = counts
  }
}
