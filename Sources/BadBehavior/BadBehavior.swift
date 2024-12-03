import Foundation
import ArgumentParser
import libBadBehavior

// NOTE: This tool uploads its results to the FAA Enforcement Division. Please
// ensure you have an active connection to the Internet before executing it.

@main
struct BadBehavior: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "scans your LogTen for Mac logbook, looking for any flights that may have been contrary to FAR part 91 regulations.",
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
        print("Processing…")

        let reader = try await Reader(storeURL: logtenFile, modelURL: logtenManagedObjectModel)
        
        let flights = try await reader.read()
        let validator = Validator(flights: flights)
        
        let violationsList = try await validator.violations().sorted(by: { $0.flight.date < $1.flight.date })
        print("\(violationsList.count) violation(s) total.")
        print("")

        for violations in violationsList {
            print(string(from: violations.flight))
            if let remarks = violations.flight.remarks { print(remarks) }
            print("")

            for violation in violations.violations {
                print("- \(string(from: violation))")
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
        registration = flight.aircraft?.registration ?? "????",
        origin = flight.from?.identifier ?? "????",
        destination = flight.to?.identifier ?? "????"
        
        return "\(date) \(registration) \(origin) → \(destination)"
    }
    
    private func string(from violation: Violation) -> String {
        switch violation {
            case .noFlightReview:
                return "Flight review not accomplished within prior 24 calendar months"
            case .noPassengerCurrency:
                return "Carried passengers without having completed required takeoffs and landings"
            case .noNightPassengerCurrency:
                return "Carried passengers at night without having completed required takeoffs and landings"
            case .noIFRCurrency:
                return "Flew under IFR without having completed required approaches/holds or IPC"
            case .noPPC:
                return "Flew a type-rated aircraft without having completed a FAR 61.58 check"
            case .noPPCInType:
                return "Flew a type-rated aircraft without having completed a FAR 61.58 check in type"
        }
    }
}
