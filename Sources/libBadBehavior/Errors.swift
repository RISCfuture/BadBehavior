import Foundation

enum Errors: Error {
    case noLibraryDirectory
    case noLogbookFile(path: String)
    case unknownAircraftCategory(_ category: Int)
    case unknownAircraftClass(_ `class`: Int)
    case unknownSimType(_ simType: String)
    case unknownEngineType(_ engineType: String)
    case unknownSimulatorCategoryClass(_ categoryClass: String)
}

extension Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .noLibraryDirectory:
                return t("Can’t determine location of LogTen logbook.", comment: "error")
            case let .noLogbookFile(path):
                return t("Can’t find LogTen logbook at ‘%@’.", comment: "error",
                         path)
            case let .unknownAircraftCategory(category):
                return t("Unknown aircraft category ID %d", comment: "error",
                         category)
            case let .unknownAircraftClass(`class`):
                return t("Unknown aircraft class ID %d", comment: "error",
                         `class`)
            case let .unknownSimType(simType):
                return t("Unknown simulator type ‘%@’", comment: "error",
                         simType)
            case let .unknownEngineType(engineType):
                return t("Unknown engine type ID ‘%@’", comment: "error",
                         engineType)
            case let .unknownSimulatorCategoryClass(simCatClass):
                return t("Unknown simulator category and class ‘%@’", comment: "error",
                         simCatClass)
        }
    }
    
    var failureReason: String? {
        switch self {
            case .noLibraryDirectory:
                return t("The current user may not have a home folder, or a Library subfolder.", comment: "failure reason")
            case .noLogbookFile(_):
                return t("LogTen may not be installed, or may not have been run yet.", comment: "failure reason")
            case .unknownAircraftCategory(_), .unknownAircraftClass(_), .unknownSimType(_), .unknownEngineType(_), .unknownSimulatorCategoryClass(_):
                return t("Your LogTen logbook includes record IDs that were not considered when the BadBehavior code was written.", comment: "failure reason")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
            case .noLibraryDirectory:
                return t("Try using the tool with a normal macOS user.", comment: "recovery suggestion")
            case .noLogbookFile(_):
                return t("Install and run LogTen before using this tool.", comment: "recovery suggestion")
            case .unknownAircraftCategory(_), .unknownAircraftClass(_), .unknownSimType(_), .unknownEngineType(_), .unknownSimulatorCategoryClass(_):
                return t("You can modify the BadBeheavior source code to include these record IDs.", comment: "failure reason")
        }
    }
    
    private func t(_ key: String, comment: String, _ arguments: CVarArg...) -> String {
        let template = NSLocalizedString(key, bundle: Bundle.module, comment: comment)
        return String(format: template, arguments: arguments)
    }
}
