import Foundation
import ArgumentParser
import libBadBehavior

// NOTE: This tool uploads its results to the FAA Enforcement Division. Please
// ensure you have an active connection to the Internet before executing it.

@main
struct BadBehavior: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "Scans your LogTen for Mac logbook, looking for any flights that may have been contrary to FAR part 91 regulations.",
        discussion: """
            In particular, it attempts to locate the following flights:
            
            * Flights made outside of the 24-month window following a BFR.
            * Flights with passengers made without the required takeoffs and landings within
            the previous 90 days (including special tailwheel requirements).
            * Night flights with passengers made without the required night takeoffs and
            landings within the previous 90 days (including special tailwheel
            requirements).
            * IFR flights made with fewer than six approaches and one hold in the preceding
            six months (and no IPC accomplished).
            * Flights in type-rated aircraft without the required FAR 61.58 check having
            been completed.
            
            It prints to the terminal a list of such flights and the reasons they are out of
            currency.
            """
    )
    
    private static let logtenDataStorePath = "Library/Group Containers/group.com.coradine.LogTenPro/LogTenProData_6583aa561ec1cc91302449b5/LogTenCoreDataStore.sql"
    private static let managedObjectModelPath = "LogTen.app/Contents/Resources/CNLogBookDocument.momd"
    
    private static var logtenDataStoreURL: URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent(logtenDataStorePath)
    }
    
    private static var managedObjectModelURL: URL { .applicationDirectory.appending(path: managedObjectModelPath) }
    
    // MARK: Arguments
    
    @Option(help: "The LogTenCoreDataStore.sql file containing the logbook entries.",
            completion: .file(extensions: ["sql"]),
            transform: { URL(filePath: $0, directoryHint: .notDirectory) })
    var logtenFile = Self.logtenDataStoreURL
    
    @Option(help: "The location of the LogTen Pro managed object model file.",
            completion: .file(extensions: ["momd"]),
            transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var logtenManagedObjectModel = Self.managedObjectModelURL
    
    // MARK: Main
    
    mutating func run() async throws {
        print(String(localized: "Processing…"))
        
        let reader = try await Reader(storeURL: logtenFile, modelURL: logtenManagedObjectModel)
        
        let flights = try await reader.read()
        let validator = Validator(flights: flights)
        
        let violationsList = try await validator.violations().sorted(by: { $0.flight.date < $1.flight.date })
        print(String(localized: "\(violationsList.count) violations total."))
        print("")
        
        for violations in violationsList {
            print(string(from: violations.flight))
            if let remarks = violations.flight.remarks { print(remarks) }
            print("")
            
            for violation in violations.violations {
                print(String(localized: "- \(string(from: violation))"))
            }
            
            print("")
            print("")
        }
    }
    
    // MARK: i18n
    
    private var datePrinter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    private func string(from flight: Flight) -> String {
        let date = datePrinter.string(from: flight.date),
            registration = flight.aircraft?.registration ?? String(localized: "????"),
            origin = flight.from?.identifier ?? String(localized: "????"),
            destination = flight.to?.identifier ?? String(localized: "????")
        
        return String(localized: "\(date) \(registration) \(origin) → \(destination)")
    }
    
    private func string(from violation: Violation) -> String {
        switch violation {
            case .noFlightReview:
                return String(localized: "Flight review not accomplished within prior 24 calendar months [61.56(c)]")
            case .noPassengerCurrency:
                return String(localized: "Carried passengers without having completed required takeoffs and landings [61.57(a)]")
            case .noNightPassengerCurrency:
                return String(localized: "Carried passengers at night without having completed required takeoffs and landings [61.57(b)]")
            case .noIFRCurrency:
                return String(localized: "Flew under IFR without having completed required approaches/holds or IPC [61.57(c)]")
            case .noPPC:
                return String(localized: "Flew a type-rated aircraft without having completed a FAR 61.58 check [61.58(a)(1)]")
            case .noPPCInType:
                return String(localized: "Flew a type-rated aircraft without having completed a FAR 61.58 check in type [61.58(a)(2)]")
            case .noNVGCurrency:
                return String(localized: "Made a takeoff or landing under NVGs without having the required NVG takeoffs and landings or proificiency checks [61.57(f)]")
            case .noNVGPassengerCurrency:
                return String(localized: "Made a takeoff or landing under NVGs with passengers without having the required NVG takeoffs and landings or proificiency checks [61.57(f)]")
            case .dualGiven8in24:
                return String(localized: "Exceeded maximum 8 hours of dual given in a 24-hour period [61.195(a)]")
            case .dualGivenTimeInType:
                return String(localized: "Gave training in a multi-engine, helicopter, or powered-lift aircraft without having 5 hours in type [61.195(f)]")
        }
    }
}
