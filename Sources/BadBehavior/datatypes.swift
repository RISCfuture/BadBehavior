import Foundation

class Aircraft {
    let registration: String

    let type: String
    let category: Category
    let `class`: Class
    let simType: SimType?
    let simCategory: Category?
    let simClass: Class?

    let tailwheel: Bool
    
    let engineType: EngineType?
    let weight: Float?

    enum Category {
        case airplane
        case glider
        case simulator
    }

    enum Class {
        case singleEngineLand
        case singleEngineSea
        case multiEngineLand
        case multiEngineSea
    }
    
    enum SimType {
        case BATD, AATD, FTD, FFS
    }
    
    enum EngineType {
        case reciprocating
        case turbofan
    }

    init(registration: String, type: String, category: Category, class: Class,
         simCategoryClass: String?, simType: SimType?, tailwheel: Bool, engineType: EngineType?, weight: Float?) {
        self.registration = registration
        self.type = type
        self.category = category
        self.`class` = `class`
        self.tailwheel = tailwheel
        self.simType = simType
        self.engineType = engineType
        self.weight = weight
        
        switch simCategoryClass {
            case "ASEL":
                simCategory = .airplane
                simClass = .singleEngineLand
            case "ASES":
                simCategory = .airplane
                simClass = .singleEngineSea
            case "AMEL":
                simCategory = .airplane
                simClass = .multiEngineLand
            case "AMES":
                simCategory = .airplane
                simClass = .multiEngineSea
            default:
                simCategory = nil
                simClass = nil
        }
    }
}

class Flight {
    let aircraft: Aircraft
    let date: Date
    let remarks: String?

    let origin: String?
    let destination: String?

    let PIC: Bool
    let trainingFlight: Bool
    let passengers: Bool

    let night: Bool
    let IFR: Bool
    let studentSolo: Bool
    let safetyPilotOnboard: Bool

    let totalTakeoffs: UInt
    let totalLandings: UInt
    let nightTakeoffs: UInt
    let nightLandings: UInt
    let fullStopLandings: UInt
    let nightFullStopLandings: UInt

    let approaches: UInt
    let holds: UInt

    let BFR: Bool
    let IPC: Bool

    var countsForIFRCurrency: Bool?

    init(aircraft: Aircraft, date: Date, remarks: String?, origin: String?,
         destination: String?, PIC: Bool, trainingFlight: Bool,
         passengers: Bool, night: Bool, IFR: Bool, studentSolo: Bool,
         safetyPilotOnboard: Bool, totalTakeoffs: UInt, totalLandings: UInt,
         nightTakeoffs: UInt, nightLandings: UInt, fullStopLandings: UInt,
         nightFullStopLandings: UInt, approaches: UInt, holds: UInt, BFR: Bool,
         IPC: Bool) {
        self.aircraft = aircraft
        self.date = date
        self.remarks = remarks
        self.origin = origin
        self.destination = destination
        self.PIC = PIC
        self.trainingFlight = trainingFlight
        self.passengers = passengers
        self.night = night
        self.IFR = IFR
        self.studentSolo = studentSolo
        self.safetyPilotOnboard = safetyPilotOnboard
        self.totalTakeoffs = totalTakeoffs
        self.totalLandings = totalLandings
        self.nightTakeoffs = nightTakeoffs
        self.nightLandings = nightLandings
        self.fullStopLandings = fullStopLandings
        self.nightFullStopLandings = nightFullStopLandings
        self.approaches = approaches
        self.holds = holds
        self.BFR = BFR
        self.IPC = IPC
    }
}
