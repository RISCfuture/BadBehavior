import Foundation

package struct Flight: IdentifiableRecord {
    
    // MARK: Properties
    
    package let id: URL
    package let aircraft: Aircraft?
    package let approaches: Array<Approach>
    package let from: Place?
    package let to: Place?
    
    package let date: Date
    
    package let PIC: Person?
    package let SIC: Person?
    package let safetyPilot: Person?
    package let passengers: Array<Person>
    
    package let PICTime: UInt // minutes
    package let nightTime: UInt // minutes
    package let actualInstrumentTime: UInt // minutes
    package let dualGivenTime: UInt // minutes
    package let dualReceivedTime: UInt // minutes
    package let soloTime: UInt // minutes
    package let NVGTime: UInt
    
    package let dayTakeoffs: UInt
    package let dayLandings: UInt
    package let nightTakeoffs: UInt
    package let nightLandings: UInt
    package let fullStopLandings: UInt
    package let nightFullStopLandings: UInt
    package let takeoffsNVG: UInt
    package let landingsNVG: UInt
    
    package let holds: UInt
    
    package let remarks: String?
    package let isFlightReview: Bool
    package let isCheckride: Bool
    package let isIPC: Bool
    package let isRecurrent: Bool
    
    // MARK: Computed Properties
    
    package var hasApproaches: Bool { !approaches.isEmpty }
    package var approachCount: Int { approaches.count }
    package var hasPassengers: Bool { passengers.count > 0 }
    package var safetyPilotOnboard: Bool { safetyPilot != nil }
    
    package var hasHolds: Bool { holds > 0 }
    package var isPIC: Bool { PICTime > 0 }
    package var isDualReceived: Bool { dualReceivedTime > 0 }
    package var isDualGiven: Bool { dualGivenTime > 0 }
    package var isStudentSolo: Bool { soloTime > 0 }
    package var isNight: Bool { nightTime > 0 }
    package var isIFR: Bool { actualInstrumentTime > 0 }
    
    package var totalTakeoffs: UInt { dayTakeoffs + nightTakeoffs }
    package var totalLandings: UInt { dayLandings + nightLandings }
    package var isTailwheel: Bool { aircraft?.tailwheel == true }
    
    // MARK: Initializers
    
    init(flight: CNFlight,
         aircraft: Aircraft,
         nightFullStopProperty: KeyPath<CNFlight, NSNumber?>,
         proficiencyProperty: KeyPath<CNFlight, String?>,
         checkrideProperty: KeyPath<CNFlight, String?>,
         safetyPilotProperty: KeyPath<CNFlightCrew, CNPerson?>,
         examinerProperty: KeyPath<CNFlightCrew, CNPerson?>
    ) {
        id = flight.objectID.uriRepresentation()
        self.aircraft = aircraft
        approaches = (flight.flight_flightApproaches?.approaches ?? [])
            .map { .init(approach: $0) }
        PIC = .init(person: flight.flight_flightCrew?.flightCrew_PIC)
        SIC = .init(person: flight.flight_flightCrew?.flightCrew_SIC)
        safetyPilot = .init(person: flight.flight_flightCrew?[keyPath: safetyPilotProperty])
        passengers = (flight.flight_flightPassengers?.passengers ?? [])
            .compactMap { .init(person: $0) }
        
        date = flight.flight_flightDate
        
        from = .init(place: flight.flight_fromPlace)
        to = .init(place: flight.flight_toPlace)
        
        PICTime = flight.flight_pic?.uintValue ?? 0
        soloTime = flight.flight_solo?.uintValue ?? 0
        nightTime = flight.flight_night?.uintValue ?? 0
        dualGivenTime = flight.flight_dualGiven?.uintValue ?? 0
        dualReceivedTime = flight.flight_dualReceived?.uintValue ?? 0
        actualInstrumentTime = flight.flight_actualInstrument?.uintValue ?? 0
        NVGTime = flight.flight_nightVisionGoggle?.uintValue ?? 0
        
        dayTakeoffs = flight.flight_dayTakeoffs?.uintValue ?? 0
        nightTakeoffs = flight.flight_nightTakeoffs?.uintValue ?? 0
        dayLandings = flight.flight_dayLandings?.uintValue ?? 0
        nightLandings = flight.flight_nightLandings?.uintValue ?? 0
        fullStopLandings = flight.flight_fullStops?.uintValue ?? 0
        nightFullStopLandings = flight[keyPath: nightFullStopProperty]?.uintValue ?? 0
        takeoffsNVG = flight.flight_nightVisionGoggleTakeoffs?.uintValue ?? 0
        landingsNVG = flight.flight_nightVisionGoggleLandings?.uintValue ?? 0
        
        holds = flight.flight_holds?.uintValue ?? 0
        
        isFlightReview = flight.flight_review?.boolValue ?? false
        isIPC = flight.flight_instrumentProficiencyCheck?.boolValue ?? false
        isRecurrent = flight[keyPath: proficiencyProperty]?.isPresent ?? false
        isCheckride = flight[keyPath: checkrideProperty]?.isPresent ?? false
        
        remarks = flight.flight_remarks
    }
}
