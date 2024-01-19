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
                return NSLocalizedString("Can’t determine location of LogTen logbook.", bundle: Bundle.module, comment: "error")
            case let .noLogbookFile(path):
                let template = NSLocalizedString("Can’t find LogTen logbook at ‘%@’.", bundle: Bundle.module, comment: "error")
                return String(format: template, path)
            case let .unknownAircraftCategory(category, type):
                let template = NSLocalizedString("Unknown aircraft category ID %d for type %@.", bundle: Bundle.module, comment: "error")
                return String(format: template, category, type)
            case let .unknownAircraftClass(`class`, type):
                let template = NSLocalizedString("Unknown aircraft class ID %d for type %@.", bundle: Bundle.module, comment: "error")
                return String(format: template, `class`, type)
            case let .unknownSimType(simType, type):
                let template = NSLocalizedString("Unknown simulator type ‘%@’ for type %@.", bundle: Bundle.module, comment: "error")
                return String(format: template, simType, type)
            case let .unknownEngineType(engineType, type):
                let template = NSLocalizedString("Unknown engine type ID ‘%@’ for type %@.", bundle: Bundle.module, comment: "error")
                return String(format: template, engineType, type)
            case let .unknownSimulatorCategoryClass(simCatClass, type):
                let template = NSLocalizedString("Unknown simulator category and class ‘%@’ for type %@.", bundle: Bundle.module, comment: "error")
                return String(format: template, simCatClass, type)
        }
    }
    
    var failureReason: String? {
        switch self {
            case .noLibraryDirectory:
                return NSLocalizedString("The current user may not have a home folder, or a Library subfolder.", bundle: Bundle.module, comment: "failure reason")
            case .noLogbookFile(_):
                return NSLocalizedString("LogTen may not be installed, or may not have been run yet.", bundle: Bundle.module, comment: "failure reason")
            case .unknownAircraftCategory(_, _), .unknownAircraftClass(_, _), .unknownSimType(_, _), .unknownEngineType(_, _), .unknownSimulatorCategoryClass(_, _):
                return NSLocalizedString("Your LogTen logbook includes record IDs that were not considered when the BadBehavior code was written.", bundle: Bundle.module, comment: "failure reason")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
            case .noLibraryDirectory:
                return NSLocalizedString("Try using the tool with a normal macOS user.", bundle: Bundle.module, comment: "recovery suggestion")
            case .noLogbookFile(_):
                return NSLocalizedString("Install and run LogTen before using this tool.", bundle: Bundle.module, comment: "recovery suggestion")
            case .unknownAircraftCategory(_, _), .unknownAircraftClass(_, _), .unknownSimType(_, _), .unknownEngineType(_, _), .unknownSimulatorCategoryClass(_, _):
                return NSLocalizedString("You can modify the BadBeheavior source code to include these record IDs.", bundle: Bundle.module, comment: "recovery suggestion")
        }
    }
}
