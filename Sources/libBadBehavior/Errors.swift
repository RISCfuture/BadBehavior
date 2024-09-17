import Foundation

enum Errors: Error {
    case noLibraryDirectory
    case noLogbookFile(path: String)
    case unknownAircraftCategory(_ category: Int, type: String)
    case unknownAircraftClass(_ `class`: Int, type: String)
    case unknownSimType(_ simType: String, type: String)
    case unknownEngineType(_ engineType: String, type: String)
    case unknownSimulatorCategoryClass(_ categoryClass: String, type: String)
}

extension Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .noLibraryDirectory:
                return String(localized: "Can’t determine location of LogTen logbook.", comment: "error")
            case let .noLogbookFile(path):
                let template = String(localized: "Can’t find LogTen logbook at ‘%@’.", comment: "error")
                return String(format: template, path)
            case let .unknownAircraftCategory(category, type):
                let template = String(localized: "Unknown aircraft category ID %d for type %@.", comment: "error")
                return String(format: template, category, type)
            case let .unknownAircraftClass(`class`, type):
                let template = String(localized: "Unknown aircraft class ID %d for type %@.", comment: "error")
                return String(format: template, `class`, type)
            case let .unknownSimType(simType, type):
                let template = String(localized: "Unknown simulator type ‘%@’ for type %@.", comment: "error")
                return String(format: template, simType, type)
            case let .unknownEngineType(engineType, type):
                let template = String(localized: "Unknown engine type ID ‘%@’ for type %@.", comment: "error")
                return String(format: template, engineType, type)
            case let .unknownSimulatorCategoryClass(simCatClass, type):
                let template = String(localized: "Unknown simulator category and class ‘%@’ for type %@.", comment: "error")
                return String(format: template, simCatClass, type)
        }
    }
    
    var failureReason: String? {
        switch self {
            case .noLibraryDirectory:
                return String(localized: "The current user may not have a home folder, or a Library subfolder.", comment: "failure reason")
            case .noLogbookFile(_):
                return String(localized: "LogTen may not be installed, or may not have been run yet.", comment: "failure reason")
            case .unknownAircraftCategory(_, _), .unknownAircraftClass(_, _), .unknownSimType(_, _), .unknownEngineType(_, _), .unknownSimulatorCategoryClass(_, _):
                return String(localized: "Your LogTen logbook includes record IDs that were not considered when the BadBehavior code was written.", comment: "failure reason")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
            case .noLibraryDirectory:
                return String(localized: "Try using the tool with a normal macOS user.", comment: "recovery suggestion")
            case .noLogbookFile(_):
                return String(localized: "Install and run LogTen before using this tool.", comment: "recovery suggestion")
            case .unknownAircraftCategory(_, _), .unknownAircraftClass(_, _), .unknownSimType(_, _), .unknownEngineType(_, _), .unknownSimulatorCategoryClass(_, _):
                return String(localized: "You can modify the BadBeheavior source code to include these record IDs.", comment: "recovery suggestion")
        }
    }
}
