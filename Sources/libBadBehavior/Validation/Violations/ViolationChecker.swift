import Foundation

protocol ViolationChecker: Sendable {
    var flights: Array<Flight> { get }
    init(flights: Array<Flight>)
    func check(flight: Flight) async throws -> Violation?
    func setup() async throws
}

extension ViolationChecker {
    func setup() async throws {}
    
    func flightsWithinLast(days: Int, ofFlight flight: Flight, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) async throws -> Array<Flight> {
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
    
    func flightsWithinLast(calendarMonths: Int, ofFlight flight: Flight, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) async throws -> Array<Flight> {
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
    
    func matchesCategory(current: Flight, past: Flight) throws -> Bool {
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
    
    func matchesClass(current: Flight, past: Flight) throws -> Bool {
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
    
    func matchesType(current: Flight, past: Flight) throws -> Bool {
        guard let currentAircraft = current.aircraft,
              let pastAircraft = past.aircraft else { return false }
        
        if currentAircraft.type.type == pastAircraft.type.type { return true }
        if pastAircraft.type.category == .simulator && pastAircraft.type.simType == .FFS {
            return pastAircraft.type.type == currentAircraft.type.type
        }
        return false
    }
}
