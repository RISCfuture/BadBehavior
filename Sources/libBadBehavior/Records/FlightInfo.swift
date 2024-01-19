import Foundation
import GRDB

fileprivate let zulu = TimeZone(secondsFromGMT: 0)
fileprivate let referenceDate: Date = {
    var components = DateComponents(timeZone: zulu, year: 2001, month: 1, day: 1)
    return Calendar.current.date(from: components)!
}()

enum Category: Int, RawRepresentable {
    case airplane = 210
    case glider = 581
    case simulator = 100
}

enum Class: Int, RawRepresentable {
    case singleEngineLand = 321
    case singleEngineSea = 146
    case multiEngineLand = 680
    case multiEngineSea = 97
}

enum SimulatorType: String, RawRepresentable {
    case BATD = "BATD"
    case AATD = "AATD"
    case FTD = "FTD"
    case FFS = "FFS"
}

enum EngineType: String, RawRepresentable {
    case twoCycle = "2 Cycle"
    case fourCycle = "4 Cycle"
    case jet = "Jet"
    case nonPowered = "Non-Powered"
    case ramjet = "Ramjet"
    case reciprocating = "Reciprocating"
    case turbine = "Turbine"
    case turbofan = "Turbo-fan"
    case turboprop = "Turbo-prop"
    case turboshaft = "Turbo-shaft"
    case unknown = "Unknown"
}

public struct FlightInfo: Codable, FetchableRecord, Identifiable, Equatable {
    
    // MARK: Associations
    
    var aircraft: Aircraft
    var aircraftType: AircraftType
    var flight: Flight
    var approaches: FlightApproaches?
    var passengers: FlightPassengers?
    var crew: FlightCrew?
    var origin: Place?
    var destination: Place?
    var engineType: CustomizationProperty?
    
    // MARK: Derived Properties
    
    public var date: Date { .init(timeInterval: TimeInterval(flight.date), since: referenceDate) }
    public var registration: String { aircraft.registration }
    public var originLID: String? { origin?.LID }
    public var destinationLID: String? { destination?.LID }
    public var remarks: String? { flight.remarks?.presence }
    
    var IPC: Bool { flight.IPC }
    var hasApproaches: Bool { approaches != nil ? !approaches!.isEmpty : false }
    var hasHolds: Bool { (flight.holds ?? 0) > 0 }
    var hasPassengers: Bool { passengers != nil ? !passengers!.isEmpty : false }
    var trainingFlight: Bool { (flight.dualReceivedTime ?? 0) > 0 }
    var PIC: Bool { (flight.PICTime ?? 0) > 0 }
    var studentSolo: Bool { (flight.soloTime ?? 0) > 0 }
    var BFR: Bool { flight.flightReview }
    var totalTakeoffs: Int { (flight.dayTakeoffs ?? 0) + (flight.nightTakeoffs ?? 0) }
    var totalLandings: Int { (flight.dayLandings ?? 0) + (flight.nightLandings ?? 0) }
    var fullStopLandings: Int { flight.fullStopLandings ?? 0 }
    var nightTakeoffs: Int { flight.nightTakeoffs ?? 0 }
    var nightFullStopLandings: Int { flight.nightFullStopLandings ?? 0 }
    var tailwheel: Bool { aircraft.tailwheel ?? false }
    var night: Bool { flight.nightTime > 0 }
    var IFR: Bool { (flight.actualInstrumentTime ?? 0) > 0 || hasApproaches }
    var safetyPilotOnboard: Bool { crew?.safetyPilot != nil }
    var approachCount: Int { approaches?.count ?? 0 }
    var recurrent: Bool { flight.FAR61_58 == "Y" }
    
    // MARK: Derived Properties - AircraftType
    
    func category() throws -> Category {
        guard let category = Category(rawValue: aircraftType.category) else {
            throw Errors.unknownAircraftCategory(aircraftType.category, type: aircraftType.type)
        }
        return category
    }
    
    func `class`() throws -> Class? {
        guard let classID = aircraftType.class else { return nil }
        guard let `class` = Class(rawValue: classID) else {
            throw Errors.unknownAircraftClass(classID, type: aircraftType.type)
        }
        return `class`
    }
    
    private func engineTypeEnum() throws -> EngineType? {
        guard let typeString = engineType?.defaultTitle else { return nil }
        guard let engineType = EngineType(rawValue: typeString) else {
            throw Errors.unknownEngineType(typeString, type: aircraftType.type)
        }
        return engineType
    }
    
    func simType() throws -> SimulatorType? {
        guard let simTypeID = aircraftType.simType else { return nil }
        guard let simType = SimulatorType(rawValue: simTypeID) else {
            throw Errors.unknownSimType(simTypeID, type: aircraftType.type)
        }
        return simType
    }
    
    func simCategory() throws -> Category? {
        guard let simCatClass = aircraftType.simAircraftCategoryClass else { return nil }
        switch simCatClass {
            case "ASEL", "ASES", "AMEL", "AMES": return .airplane
            case "GLI": return .glider
            default: throw Errors.unknownSimulatorCategoryClass(simCatClass, type: aircraftType.type)
        }
    }
    
    func simClass() throws -> Class? {
        guard let simCatClass = aircraftType.simAircraftCategoryClass else { return nil }
        switch simCatClass {
            case "ASEL": return .singleEngineLand
            case "ASES": return .singleEngineSea
            case "AMEL": return .multiEngineLand
            case "AMES": return .multiEngineSea
            case "GLI": return nil
            default: throw Errors.unknownSimulatorCategoryClass(simCatClass, type: aircraftType.type)
        }
    }
    
    func typeRatingRequired() throws -> Bool {
        switch try engineTypeEnum() {
            case .turboshaft, .turboprop, .turbofan, .turbine, .ramjet, .jet:
                return true
            default: break
        }
        guard let weight = aircraft.weight else { return false }
        return weight >= 12500
    }
    
    // MARK: Identifiable and Equatable
    
    public var id: Int { flight.id }
    
    public static func == (lhs: FlightInfo, rhs: FlightInfo) -> Bool { lhs.id == rhs.id }
    
    enum CodingKeys: String, CodingKey {
        case aircraft
        case aircraftType
        case flight
        case approaches
        case passengers
        case crew
        case origin
        case destination
    }
}
