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
                return "Couldn’t create Core Data store for “\(path.lastPathComponent)”"
            case .missingProperty:
                return "A required property is missing"
            case .invalidClass:
                return "Aircraft category/class pair is invalid"
            case let .missingClass(type):
                return "Missing aircraft class for aircraft type “\(type)”"
            case let .missingSimulatorType(type):
                return "Missing Sim Type for aircraft type “\(type)”"
        }
    }
    
    package var failureReason: String? {
        switch self {
            case .couldntCreateStore:
                return "The LogTen Pro data either doesn’t exist, is invalid, or is a newer version."
            case let .missingProperty(property, model):
                return "\(model) must have a property named “\(property)”."
            case let .invalidClass(`class`, category):
                return "“\(`class`)” is not a valid aircraft class for category “\(category)”."
            case .missingClass:
                return "Aircraft category requires a class."
            case .missingSimulatorType:
                return "Simulator requires a Sim Type entry."
        }
    }
    
    package var recoverySuggestion: String? {
        switch self {
            case .couldntCreateStore:
                return "Install LogTen Pro if it is not installed, or check that its version is compatible with this tool."
            case let .missingProperty(property, model):
                return "Add a property called “\(property)” to \(model)."
            case .invalidClass:
                return "Modify the aircraft to correct its category and class."
            case .missingClass:
                return "Add the aircraft class to the Aircraft record."
            case .missingSimulatorType:
                return "Add the Sim Type entry to the Aircraft record for the simulator."
        }
    }
}
