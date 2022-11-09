import Foundation
import Dispatch

public class Validator {
    // MARK: Fields
    
    private var flights: Array<FlightInfo>
    private var countsForIFRCurrency = Dictionary<Int, Bool>()
    private var countsForIFRCurrencyMutex = DispatchSemaphore(value: 1)
    
    // MARK: Init
    
    public init(flights: Array<FlightInfo>) {
        self.flights = flights.sorted(by: { $0.date < $1.date })
    }
    
    public func precalculateIFRCurrency() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            for flight in flights {
                group.addTask {
                    if flight.IPC {
                        self.storeIFRCurrency(flight: flight, countsForIFRCurrency: true)
                        return
                    }
                    if !flight.hasApproaches && !flight.hasHolds {
                        self.storeIFRCurrency(flight: flight, countsForIFRCurrency: false)
                    }
                    
                    let eligibleFlights = try await self.flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true)
                    if (eligibleFlights.first { $0.IPC }) != nil {
                        self.storeIFRCurrency(flight: flight, countsForIFRCurrency: true)
                        return
                    }
                    let totalApproaches = eligibleFlights.reduce(0) { $0 + (self.flightCountsForIFRCurrency($1) ? $1.approachCount : 0) }
                    let totalHolds = eligibleFlights.reduce(0) { $0 + (self.flightCountsForIFRCurrency($1) ? ($1.flight.holds ?? 0) : 0) }
                    
                    self.storeIFRCurrency(flight: flight, countsForIFRCurrency: (totalApproaches >= 6 && totalHolds >= 1))
                }
            }
        }
    }
    
    // MARK: Scanner
    
    public func violations() async throws -> Array<Violations> {
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
    
    public func noFlightReview(flight: FlightInfo) async throws -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if flight.studentSolo || flight.BFR { return false }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 24, ofFlight: flight)
        return eligibleFlights.first { $0.BFR } == nil
    }
    
    public func noPassengerCurrency(flight: FlightInfo) async throws -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if !flight.hasPassengers { return false }
        
        let eligibleFlights = try await flightsWithinLast(days: 90, ofFlight: flight, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true)
        let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.totalTakeoffs }
        let totalLandings = eligibleFlights.reduce(0) { $0 + $1.totalLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return true }
        
        if flight.tailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.tailwheel }
            let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.totalTakeoffs }
            let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.fullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return true }
        }
        
        return false
    }
    
    public func noNightPassengerCurrency(flight: FlightInfo) async throws -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if !flight.hasPassengers { return false }
        if !flight.night { return false }
        
        let eligibleFlights = try await flightsWithinLast(days: 90, ofFlight: flight, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true)
        let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.nightTakeoffs }
        let totalLandings = eligibleFlights.reduce(0) { $0 + $1.nightFullStopLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return true }
        
        if flight.tailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.tailwheel }
            let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.nightTakeoffs }
            let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.nightFullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return true }
        }
        
        return false
    }
    
    public func noIFRCurrency(flight: FlightInfo) async throws -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if !flight.IFR || flight.safetyPilotOnboard || flight.IPC { return false }
        
        let eligibleFlights = try await withThrowingTaskGroup(of: FlightInfo?.self, returning: Array<FlightInfo>.self) { group in
            for f in try await flightsWithinLast(calendarMonths: 6, ofFlight: flight, matchingCategory: true) {
                group.addTask {
                    if !f.hasApproaches && !f.hasHolds && !f.IPC { return nil }
                    return try await self.isWithinGracePeriod(f) ? f : nil
                }
            }
            
            var flights = Array<FlightInfo>()
            for try await f in group {
                if let f = f { flights.append(f) }
            }
            return flights
        }
        
        // check for IPC first
        if eligibleFlights.first(where: { $0.IPC }) != nil { return false }
        
        // verify that there were 6a/1h within past 6mo
        let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount }
        let hold = (eligibleFlights.first { $0.hasHolds } != nil)
        // you probably intercepted and tracked some radials, right??
        
        return (totalApproaches < 6 || !hold)
    }
    
    public func noPPC(flight: FlightInfo) async throws -> Bool {
        if flight.trainingFlight || flight.recurrent { return false }
        if !(try flight.typeRatingRequired()) { return false }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 12, ofFlight: flight)
        return eligibleFlights.first { $0.recurrent } == nil
    }
    
    public func noPPCInType(flight: FlightInfo) async throws -> Bool {
        if flight.trainingFlight || flight.recurrent { return false }
        if !(try flight.typeRatingRequired()) { return false }
        
        let eligibleFlights = try await flightsWithinLast(calendarMonths: 24, ofFlight: flight, matchingTypeIfRequired: true)
        return eligibleFlights.first { $0.recurrent } == nil
    }
    
    // MARK: Private
    
    // flights with practice approaches don't count towards currency unless they
    // are within 12 months of the preceding practice approaches or IPC
    private func isWithinGracePeriod( _ flight: FlightInfo) async throws -> Bool {
        if let counts = precalculatedFlightCountsForIFRCurrency(flight) { return counts }
        
        let eligibleFlights = try await withThrowingTaskGroup(of: FlightInfo?.self, returning: Array<FlightInfo>.self) { group in
            for f in try await flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true) {
                group.addTask {
                    if !f.hasApproaches && !f.hasHolds && !f.IPC { return nil }
                    return try await self.isWithinGracePeriod(f) ? f : nil
                }
            }
            
            var flights = Array<FlightInfo>()
            for try await f in group {
                if let f = f { flights.append(f) }
            }
            return flights
        }
        
        // check for IPC first
        if eligibleFlights.first(where: { $0.IPC }) != nil { return false }
        
        let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approachCount }
        let hold = (eligibleFlights.first { $0.hasHolds } != nil)
        
        let counts = (totalApproaches < 6 || !hold)
        storeIFRCurrency(flight: flight, countsForIFRCurrency: counts)
        return counts
    }
    
    private func flightsWithinLast(days: Int, ofFlight flight: FlightInfo, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) async throws -> Array<FlightInfo> {
        var referenceDate = Calendar.current.date(byAdding: .day, value: -days, to: flight.date)!
        referenceDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: referenceDate)!
        
        return try await withThrowingTaskGroup(of: FlightInfo?.self, returning: Array<FlightInfo>.self) { group in
            let referenceDate = referenceDate
            for f in flights {
                group.addTask {
                    return try (f != flight &&
                            (referenceDate...flight.date).contains(f.date) &&
                            (!matchingCategory || self.matchesCategory(current: flight, past: f)) &&
                            (!matchingClass || self.matchesClass(current: flight, past: f)) &&
                                (!matchingTypeIfRequired || !flight.typeRatingRequired() || self.matchesType(current: flight, past: f))) ?
                    f : nil
                }
            }
            
            var flights = Array<FlightInfo>()
            for try await f in group {
                if let f = f { flights.append(f) }
            }
            return flights
        }
    }
    
    private func flightsWithinLast(calendarMonths: Int, ofFlight flight: FlightInfo, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) async throws -> Array<FlightInfo> {
        var referenceDate = Calendar.current.date(byAdding: .month, value: -calendarMonths, to: flight.date)!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: referenceDate)
        components.day = 1
        referenceDate = Calendar.current.date(from: components)!
        
        return try await withThrowingTaskGroup(of: FlightInfo?.self, returning: Array<FlightInfo>.self) { group in
            let referenceDate = referenceDate
            for f in flights {
                group.addTask {
                    return try (f != flight &&
                            (referenceDate...flight.date).contains(f.date) &&
                            (!matchingCategory || self.matchesCategory(current: flight, past: f)) &&
                            (!matchingClass || self.matchesClass(current: flight, past: f)) &&
                                (!matchingTypeIfRequired || !flight.typeRatingRequired() || self.matchesType(current: flight, past: f))) ?
                    f : nil
                }
            }
            
            var flights = Array<FlightInfo>()
            for try await f in group {
                if let f = f { flights.append(f) }
            }
            return flights
        }
    }
    
    private func matchesCategory(current: FlightInfo, past: FlightInfo) throws -> Bool {
        let currentCategory = try current.category()
        let pastCategory = try past.category()
        
        if currentCategory == .simulator { return true }
        if currentCategory == pastCategory { return true }
        if try pastCategory == .simulator && past.simType() == .FFS {
            return try past.simCategory() == currentCategory
        }
        return false
    }
    
    private func matchesClass(current: FlightInfo, past: FlightInfo) throws -> Bool {
        let currentClass = try current.class()
        let pastClass = try past.class()
        
        if currentClass == pastClass { return true }
        if try past.category() == .simulator && past.simType() == .FFS {
            return try past.simClass() == currentClass
        }
        return false
    }
    
    private func matchesType(current: FlightInfo, past: FlightInfo) throws -> Bool {
        if current.aircraftType.type == past.aircraftType.type { return true }
        if try past.category() == .simulator && past.simType() == .FFS {
            return past.aircraftType.simType == current.aircraftType.type
        }
        return false
    }
    
    private func flightCountsForIFRCurrency(_ flight: FlightInfo) -> Bool {
        countsForIFRCurrencyMutex.wait()
        defer { countsForIFRCurrencyMutex.signal() }
        
        return countsForIFRCurrency[flight.id] ?? false
    }
    
    private func precalculatedFlightCountsForIFRCurrency(_ flight: FlightInfo) -> Bool? {
        countsForIFRCurrencyMutex.wait()
        defer { countsForIFRCurrencyMutex.signal() }
        
        return countsForIFRCurrency[flight.id]
    }
    
    private func storeIFRCurrency(flight: FlightInfo, countsForIFRCurrency counts: Bool) {
        countsForIFRCurrencyMutex.wait()
        defer { countsForIFRCurrencyMutex.signal() }
        
        countsForIFRCurrency[flight.id] = counts
    }
}
