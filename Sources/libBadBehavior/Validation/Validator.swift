import Foundation

package actor Validator {
    // MARK: Fields
    
    private var flights: Array<Flight>
    private var countsForIFRCurrency = Dictionary<URL, Bool>()
    
    // MARK: Init
    
    package init(flights: Array<Flight>) {
        self.flights = flights.sorted(by: { $0.date < $1.date })
    }
    
    package func precalculateIFRCurrency() async throws {
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
                    
                    let eligibleFlights = try await self.flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true)
                    if (eligibleFlights.first { $0.isIPC }) != nil {
                        await self.storeIFRCurrency(flight: flight, countsForIFRCurrency: true)
                        return
                    }
                    var totalApproaches = 0, totalHolds: UInt = 0
                    for eligibleFlight in eligibleFlights {
                        totalApproaches += await (self.flightCountsForIFRCurrency(eligibleFlight) ? eligibleFlight.approachCount : 0)
                        totalHolds += await (self.flightCountsForIFRCurrency(eligibleFlight) ? eligibleFlight.holds : 0)
                    }
                    
                    await self.storeIFRCurrency(flight: flight, countsForIFRCurrency: (totalApproaches >= 6 && totalHolds >= 1))
                }
            }
        }
    }
    
    // MARK: Scanner
    
    package func violations() async throws -> Array<Violations> {
        return try await withThrowingTaskGroup(of: Violations?.self, returning: Array<Violations>.self) { group in
            for flight in self.flights {
                group.addTask {
                    var flightViolations = Array<Violation>()
                    if try await self.noFlightReview(flight: flight) { flightViolations.append(.noFlightReview) }
                    if try await self.noPassengerCurrency(flight: flight) { flightViolations.append(.noPassengerCurrency) }
                    if try await self.noNightPassengerCurrency(flight: flight) { flightViolations.append(.noNightPassengerCurrency) }
                    if try await self.noIFRCurrency(flight: flight) { flightViolations.append(.noIFRCurrency) }
                    if try await self.noPPC(flight: flight) { flightViolations.append(.noPPC) }
                    if try await self.noPPCInType(flight: flight) { flightViolations.append(.noPPCInType) }
                    
                    if !flightViolations.isEmpty { return Violations(flight: flight, violations: flightViolations) }
                    else { return nil }
                }
            }
            
            var violations = Array<Violations>()
            for try await v in group {
                if let v = v { violations.append(v) }
            }
            return violations
        }
    }
    
    // MARK: Checkers
    
    package func noFlightReview(flight: Flight) async throws -> Bool {
        if flight.isDualReceived || !flight.isPIC { return false }
        if flight.isStudentSolo || flight.isFlightReview || flight.isCheckride { return false }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 24, ofFlight: flight)
        return eligibleFlights.first { $0.isFlightReview || $0.isCheckride } == nil
    }
    
    package func noPassengerCurrency(flight: Flight) async throws -> Bool {
        if flight.isDualReceived || !flight.isPIC { return false }
        if !flight.hasPassengers { return false }
        
        let eligibleFlights = try await flightsWithinLast(days: 90, ofFlight: flight, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true),
            totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.totalTakeoffs },
            totalLandings = eligibleFlights.reduce(0) { $0 + $1.totalLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return true }
        
        if flight.isTailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.isTailwheel },
                tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.totalTakeoffs },
                tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.fullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return true }
        }
        
        return false
    }
    
    package func noNightPassengerCurrency(flight: Flight) async throws -> Bool {
        if flight.isDualReceived || !flight.isPIC { return false }
        if !flight.hasPassengers { return false }
        if !flight.isNight { return false }
        
        let eligibleFlights = try await flightsWithinLast(days: 90, ofFlight: flight, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true)
        let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.nightTakeoffs }
        let totalLandings = eligibleFlights.reduce(0) { $0 + $1.nightFullStopLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return true }
        
        if flight.isTailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.isTailwheel }
            let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.nightTakeoffs }
            let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.nightFullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return true }
        }
        
        return false
    }
    
    package func noIFRCurrency(flight: Flight) async throws -> Bool {
        if flight.isDualReceived || !flight.isPIC { return false }
        if !flight.isIFR || flight.safetyPilotOnboard || flight.isIPC { return false }
        
        let eligibleFlights = try await withThrowingTaskGroup(of: Flight?.self, returning: Array<Flight>.self) { group in
            for f in try await flightsWithinLast(calendarMonths: 6, ofFlight: flight, matchingCategory: true) {
                group.addTask {
                    if !f.hasApproaches && !f.hasHolds && !f.isIPC { return nil }
                    return try await self.isWithinGracePeriod(f) ? f : nil
                }
            }
            
            var flights = Array<Flight>()
            for try await f in group {
                if let f = f { flights.append(f) }
            }
            return flights
        }
        
        // check for IPC first
        if eligibleFlights.first(where: { $0.isIPC }) != nil { return false }
        
        // verify that there were 6a/1h within past 6mo
        let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount },
            hold = (eligibleFlights.first { $0.hasHolds } != nil)
        // you probably intercepted and tracked some radials, right??
        
        return (totalApproaches < 6 || !hold)
    }
    
    package func noPPC(flight: Flight) async throws -> Bool {
        guard let aircraft = flight.aircraft else { return false }
        
        if flight.isDualReceived   || flight.isRecurrent { return false }
        if !aircraft.typeRatingRequired { return false }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 12, ofFlight: flight)
        return eligibleFlights.first { $0.isRecurrent } == nil
    }
    
    package func noPPCInType(flight: Flight) async throws -> Bool {
        guard let aircraft = flight.aircraft else { return false }
        
        if flight.isDualReceived || flight.isRecurrent { return false }
        if !aircraft.typeRatingRequired { return false }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 24, ofFlight: flight, matchingTypeIfRequired: true)
        return eligibleFlights.first { $0.isRecurrent } == nil
    }
    
    // MARK: Private
    
    // flights with practice approaches don't count towards currency unless they
    // are within 12 months of the preceding practice approaches or IPC
    private func isWithinGracePeriod( _ flight: Flight) async throws -> Bool {
        if let counts = precalculatedFlightCountsForIFRCurrency(flight) { return counts }
        
        let eligibleFlights = try await withThrowingTaskGroup(of: Flight?.self, returning: Array<Flight>.self) { group in
            for f in try await flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true) {
                group.addTask {
                    if !f.hasApproaches && !f.hasHolds && !f.isIPC { return nil }
                    return try await self.isWithinGracePeriod(f) ? f : nil
                }
            }
            
            var flights = Array<Flight>()
            for try await f in group {
                if let f = f { flights.append(f) }
            }
            return flights
        }
        
        // check for IPC first
        if eligibleFlights.first(where: { $0.isIPC }) != nil { return false }
        
        let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount },
            hold = (eligibleFlights.first { $0.hasHolds } != nil)
        
        let counts = (totalApproaches < 6 || !hold)
        storeIFRCurrency(flight: flight, countsForIFRCurrency: counts)
        return counts
    }
    
    private func flightsWithinLast(days: Int, ofFlight flight: Flight, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) async throws -> Array<Flight> {
        guard let aircraft = flight.aircraft else { return [] }
        
        var referenceDate = Calendar.current.date(byAdding: .day, value: -days, to: flight.date)!
        referenceDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: referenceDate)!
        
        return try flights.filter { f in
            let differentFlight = f != flight,
                withinDateRange = (referenceDate...flight.date).contains(f.date),
                matchesCategory = try (!matchingCategory || self.matchesCategory(current: flight, past: f)),
                matchesClass = try (!matchingClass || self.matchesClass(current: flight, past: f)),
                matchesType = try (!matchingTypeIfRequired || !aircraft.typeRatingRequired || self.matchesType(current: flight, past: f))
            
            return differentFlight && withinDateRange && matchesCategory && matchesClass && matchesType
        }
    }
    
    private func flightsWithinLast(calendarMonths: Int, ofFlight flight: Flight, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) async throws -> Array<Flight> {
        guard let aircraft = flight.aircraft else { return [] }
        
        var referenceDate = Calendar.current.date(byAdding: .month, value: -calendarMonths, to: flight.date)!,
            components = Calendar.current.dateComponents([.year, .month, .day], from: referenceDate)
        components.day = 1
        referenceDate = Calendar.current.date(from: components)!
        
        return try flights.filter { f in
            let differentFlight = f != flight,
                matchesDate = (referenceDate...flight.date).contains(f.date),
                matchesCategory = try (!matchingCategory || self.matchesCategory(current: flight, past: f)),
                matchesClass = try (!matchingClass || self.matchesClass(current: flight, past: f)),
                matchesType = try (!matchingTypeIfRequired || !aircraft.typeRatingRequired || self.matchesType(current: flight, past: f))
            return differentFlight && matchesDate && matchesCategory && matchesClass && matchesType
        }
    }
    
    private func matchesCategory(current: Flight, past: Flight) throws -> Bool {
        guard let currentAircraft = current.aircraft,
              let pastAircraft = past.aircraft else { return false }
        let currentCategory = currentAircraft.type.category,
            pastCategory = pastAircraft.type.category
        
        if currentCategory == .simulator { return true }
        if currentCategory == pastCategory { return true }
        if pastCategory == .simulator && pastAircraft.type.simType == .FFS {
            return pastAircraft.type.simCategory == currentCategory
        }
        return false
    }
    
    private func matchesClass(current: Flight, past: Flight) throws -> Bool {
        guard let currentAircraft = current.aircraft,
              let pastAircraft = past.aircraft else { return false }
        let currentClass = currentAircraft.type.class,
            pastClass = pastAircraft.type.class,
            pastCategory = pastAircraft.type.category
        
        if currentClass == pastClass { return true }
        if pastCategory == .simulator && pastAircraft.type.simType == .FFS {
            return pastAircraft.type.simClass == currentClass
        }
        return false
    }
    
    private func matchesType(current: Flight, past: Flight) throws -> Bool {
        guard let currentAircraft = current.aircraft,
              let pastAircraft = past.aircraft else { return false }
        
        if currentAircraft.type.type == pastAircraft.type.type { return true }
        if pastAircraft.type.category == .simulator && pastAircraft.type.simType == .FFS {
            return pastAircraft.type.type == currentAircraft.type.type
        }
        return false
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
