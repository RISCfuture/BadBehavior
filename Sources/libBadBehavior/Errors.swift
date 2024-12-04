import Foundation

package enum Errors: Swift.Error {
    case couldntCreateStore(path: URL)
    case missingProperty(_ property: String, model: String)
    case invalidClass(_ `class`: AircraftType.Class, forCategory: AircraftType.Category)
    case missingClass(type: String)
    case missingSimulatorType(type: String)
}

extension Errors: LocalizedError {
    package var errorDescription: String? {
        switch self {
            case let .couldntCreateStore(path):
                return String(localized: "Couldn’t create Core Data store for “\(path.lastPathComponent)”")
            case .missingProperty:
                return String(localized: "A required property is missing")
            case .invalidClass:
                return String(localized: "Aircraft category/class pair is invalid")
            case let .missingClass(type):
                return String(localized: "Missing aircraft class for aircraft type “\(type)”")
            case let .missingSimulatorType(type):
                return String(localized: "Missing Sim Type for aircraft type “\(type)”")
        }
    }
    
    package var failureReason: String? {
        switch self {
            case .couldntCreateStore:
                return String(localized: "The LogTen Pro data either doesn’t exist, is invalid, or is a newer version.")
            case let .missingProperty(property, model):
                return String(localized: "\(model) must have a property named “\(property)”.")
            case let .invalidClass(`class`, category):
                return String(localized: "“\(`class`.localizedDescription)” is not a valid aircraft class for category “\(category.localizedDescription)”.")
            case .missingClass:
                return String(localized: "Aircraft category requires a class.")
            case .missingSimulatorType:
                return String(localized: "Simulator requires a Sim Type entry.")
        }
    }
    
    package var recoverySuggestion: String? {
        switch self {
            case .couldntCreateStore:
                return String(localized: "Install LogTen Pro if it is not installed, or check that its version is compatible with this tool.")
            case let .missingProperty(property, model):
                return String(localized: "Add a property called “\(property)” to \(model).")
            case .invalidClass:
                return String(localized: "Modify the aircraft to correct its category and class.")
            case .missingClass:
                return String(localized: "Add the aircraft class to the Aircraft record.")
            case .missingSimulatorType:
                return String(localized: "Add the Sim Type entry to the Aircraft record for the simulator.")
        }
    }
}
