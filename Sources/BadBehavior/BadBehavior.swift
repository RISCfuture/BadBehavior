import Foundation
import ArgumentParser
import libBadBehavior

// NOTE: This tool uploads its results to the FAA Enforcement Division. Please
// ensure you have an active connection to the Internet before executing it.

@main
struct BadBehavior: AsyncParsableCommand {
    
    // MARK: Arguments
    
    @Argument(help: "The location of the LogTenCoreDataStore.sql file",
              completion: .file(extensions: [".sql"]))
    var databasePath: String?
    
    // MARK: Main
    
    mutating func run() async throws {
        puts("Processing…")
        
        let connection = try Connection(logbookPath: databasePath)
        
        let flights = connection.eachFlight()
        let validator = try await Validator(flights: flights.collect())
        try await validator.precalculateIFRCurrency()
        
        let violationsList = try await validator.violations().sorted(by: { $0.flight.date < $1.flight.date })
        puts("\(violationsList.count) violation(s) total.")
        puts("")

        for violations in violationsList {
            print(string(from: violations.flight))
            if let remarks = violations.flight.remarks { print(remarks) }
            print("")

            for violation in violations.violations {
                print(String(format: violationFormat, string(from: violation)))
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
    
    private var missingAirportID: String { NSLocalizedString("????", bundle: Bundle.module, comment: "missing airport ID") }
    private var flightFormat: String { NSLocalizedString("%@ %@ %@ → %@", bundle: Bundle.module, comment: "flight info string [date, registration, origin, destination]") }
    private var violationFormat: String { NSLocalizedString("- %@", bundle: Bundle.module, comment: "violation list item") }
    
    private func string(from flight: FlightInfo) -> String {
        String(format: flightFormat,
               datePrinter.string(from: flight.date),
               flight.registration,
               flight.originLID ?? missingAirportID,
               flight.destinationLID ?? missingAirportID)
    }
    
    private func string(from violation: Violation) -> String {
        switch violation {
            case .noFlightReview:
                return NSLocalizedString("Flight review not accomplished within prior 24 calendar months", bundle: Bundle.module, comment: "violation")
            case .noPassengerCurrency:
                return NSLocalizedString("Carried passengers without having completed required takeoffs and landings", bundle: Bundle.module, comment: "violation")
            case .noNightPassengerCurrency:
                return NSLocalizedString("Carried passengers at night without having completed required takeoffs and landings", bundle: Bundle.module, comment: "violation")
            case .noIFRCurrency:
                return NSLocalizedString("Flew under IFR without having completed required approaches/holds or IPC", bundle: Bundle.module, comment: "violation")
            case .noPPC:
                return NSLocalizedString("Flew a type-rated aircraft without having completed a FAR 61.58 check", bundle: Bundle.module, comment: "violation")
            case .noPPCInType:
                return NSLocalizedString("Flew a type-rated aircraft without having completed a FAR 61.58 check in type", bundle: Bundle.module, comment: "violation")
        }
    }
}
