import Foundation

class Checker {
    let flight: Flight
    let caller: CommandLineTool

    init(_ flight: Flight, caller: CommandLineTool) {
        self.flight = flight
        self.caller = caller
        precalculateIFRCurrency()
    }

    // MARK: Checkers

    func outOfBFRCurrency() -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if flight.studentSolo || flight.BFR { return false }

        let eligibleFlights = flightsWithinLast(calendarMonths: 24)
        return eligibleFlights.first { $0.BFR } == nil
    }

    func outOfPassengerCurrency() -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if !flight.passengers { return false }

        let eligibleFlights = flightsWithinLast(days: 90, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true)
        let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.totalTakeoffs }
        let totalLandings = eligibleFlights.reduce(0) { $0 + $1.totalLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return true }

        if flight.aircraft.tailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.aircraft.tailwheel }
            let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.totalTakeoffs }
            let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.fullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return true }
        }

        return false
    }

    func outOfNightPassengerCurrency() -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if !flight.passengers { return false }
        if !flight.night { return false }

        let eligibleFlights = flightsWithinLast(days: 90, matchingCategory: true, matchingClass: true, matchingTypeIfRequired: true)
        let totalTakeoffs = eligibleFlights.reduce(0) { $0 + $1.nightTakeoffs }
        let totalLandings = eligibleFlights.reduce(0) { $0 + $1.nightFullStopLandings }
        if totalTakeoffs < 3 || totalLandings < 3 { return true }

        if flight.aircraft.tailwheel {
            let tailwheelFlights = eligibleFlights.filter { $0.aircraft.tailwheel }
            let tailwheelTakeoffs = tailwheelFlights.reduce(0) { $0 + $1.nightTakeoffs }
            let tailwheelLandings = tailwheelFlights.reduce(0) { $0 + $1.nightFullStopLandings }
            if tailwheelTakeoffs < 3 || tailwheelLandings < 3 { return true }
        }

        return false
    }

    func outOfIFRCurrency() -> Bool {
        if flight.trainingFlight || !flight.PIC { return false }
        if !flight.IFR || flight.safetyPilotOnboard || flight.IPC { return false }

        let eligibleFlights = flightsWithinLast(calendarMonths: 6, matchingCategory: true).filter {
            ($0.approaches > 0 || $0.holds > 0 || $0.IPC) && isWithinGracePeriod($0)
        }

        // check for IPC first
        if eligibleFlights.first(where: { $0.IPC }) != nil { return false }

        // verify that there were 6a/1h within past 6mo
        let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approaches }
        let hold = (eligibleFlights.first { $0.holds > 0 } != nil)
        // you probably intercepted and tracked some radials, right??

        return (totalApproaches < 6 || !hold)
    }

    // MARK: Privates

    // flights with practice approaches don't count towards currency unless they
    // are within 12 months of the preceding practice approaches or IPC
    private func isWithinGracePeriod(_ flight: Flight) -> Bool {
        if flight.countsForIFRCurrency != nil { return flight.countsForIFRCurrency! }

        let eligibleFlights = flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true).filter {
            ($0.approaches > 0 || $0.holds > 0 || $0.IPC) && isWithinGracePeriod($0)
        }

        // check for IPC first
        if eligibleFlights.first(where: { $0.IPC }) != nil { return false }

        let totalApproaches = eligibleFlights.reduce(0) { $0 + $1.approaches }
        let hold = (eligibleFlights.first { $0.holds > 0 } != nil)

        flight.countsForIFRCurrency = (totalApproaches < 6 || !hold)
        return flight.countsForIFRCurrency!
    }

    private func flightsWithinLast(days: Int, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) -> Array<Flight> {
        return flightsWithinLast(days: days, ofFlight: self.flight, matchingCategory: matchingCategory, matchingClass: matchingClass, matchingTypeIfRequired: matchingTypeIfRequired)
    }

    private func flightsWithinLast(days: Int, ofFlight flight: Flight, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) -> Array<Flight> {
        var referenceDate = Calendar.current.date(byAdding: .day, value: -days, to: flight.date)!
        referenceDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: referenceDate)!

        return caller.flights.filter {
            $0 !== flight &&
                (referenceDate...flight.date).contains($0.date) &&
            (!matchingCategory || matchesCategory(currentAircraft: flight.aircraft, pastAircraft: $0.aircraft)) &&
            (!matchingClass || matchesClass(currentAircraft: flight.aircraft, pastAircraft: $0.aircraft)) &&
            (!matchingTypeIfRequired || !typeRatingRequired(flight.aircraft) || matchesType(currentAircraft: flight.aircraft, pastAircraft: $0.aircraft))
        }
    }

    private func flightsWithinLast(calendarMonths: Int, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) -> Array<Flight> {
        return flightsWithinLast(calendarMonths: calendarMonths, ofFlight: self.flight, matchingCategory: matchingCategory, matchingClass: matchingClass, matchingTypeIfRequired: matchingTypeIfRequired)
    }

    private func flightsWithinLast(calendarMonths: Int, ofFlight flight: Flight, matchingCategory: Bool = false, matchingClass: Bool = false, matchingTypeIfRequired: Bool = false) -> Array<Flight> {
        var referenceDate = Calendar.current.date(byAdding: .month, value: -calendarMonths, to: flight.date)!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: referenceDate)
        components.day = 1
        referenceDate = Calendar.current.date(from: components)!

        return caller.flights.filter {
            $0 !== flight &&
                (referenceDate...flight.date).contains($0.date) &&
            (!matchingCategory || matchesCategory(currentAircraft: flight.aircraft, pastAircraft: $0.aircraft)) &&
            (!matchingClass || matchesClass(currentAircraft: flight.aircraft, pastAircraft: $0.aircraft)) &&
            (!matchingTypeIfRequired || !typeRatingRequired(flight.aircraft) || matchesType(currentAircraft: flight.aircraft, pastAircraft: $0.aircraft))
        }
    }
    
    private func matchesCategory(currentAircraft: Aircraft, pastAircraft: Aircraft) -> Bool {
        if currentAircraft.category == .simulator { return true }
        if currentAircraft.category == pastAircraft.category { return true }
        if pastAircraft.category == .simulator && pastAircraft.simType == .FFS {
            return pastAircraft.simCategory == currentAircraft.category
        }
        return false
    }
    
    private func matchesClass(currentAircraft: Aircraft, pastAircraft: Aircraft) -> Bool {
        if currentAircraft.class == pastAircraft.class { return true }
        if pastAircraft.category == .simulator && pastAircraft.simType == .FFS {
            return pastAircraft.simClass == currentAircraft.class
        }
        return false
    }
    
    private func matchesType(currentAircraft: Aircraft, pastAircraft: Aircraft) -> Bool {
        if currentAircraft.type == pastAircraft.type { return true }
        if pastAircraft.category == .simulator && pastAircraft.simType == .FFS {
            return pastAircraft.type == currentAircraft.type
        }
        return false
    }
    
    private func typeRatingRequired(_ aircraft: Aircraft) -> Bool {
        guard let engineType = aircraft.engineType else { return false }
        if engineType == .turbofan { return true }
        
        guard let weight = aircraft.weight else { return false }
        if weight > 12500 { return true }
        
        return false
    }

    private func precalculateIFRCurrency() {
        caller.flights.sort { $0.date < $1.date }
        for flight in caller.flights {
            if flight.IPC {
                flight.countsForIFRCurrency = true
                continue
            }
            if flight.approaches == 0 && flight.holds == 0 {
                flight.countsForIFRCurrency = false
                continue
            }

            let eligibleFlights = flightsWithinLast(calendarMonths: 12, ofFlight: flight, matchingCategory: true)
            if (eligibleFlights.first { $0.IPC }) != nil {
                flight.countsForIFRCurrency = true
                continue
            }
            let totalApproaches = eligibleFlights.reduce(0) { $0 + ($1.countsForIFRCurrency == true ? $1.approaches : 0) }
            let totalHolds = eligibleFlights.reduce(0) { $0 + ($1.countsForIFRCurrency == true ? $1.holds : 0) }

            flight.countsForIFRCurrency = (totalApproaches >= 6 && totalHolds >= 1)
        }
    }
}

