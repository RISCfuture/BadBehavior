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
    
    // MARK: Arguments
    
    @Argument(help: "The location of the LogTenCoreDataStore.sql file",
              completion: .file(extensions: [".sql"]))
    var databasePath: String?
    
    // MARK: Main
    
    mutating func run() async throws {
        print(String(localized: "Processing…"))

        let connection = try Connection(logbookPath: databasePath)
        
        let flights = await connection.eachFlight()
        let validator = try await Validator(flights: flights.collect())
        try await validator.precalculateIFRCurrency()
        
        let violationsList = try await validator.violations().sorted(by: { $0.flight.date < $1.flight.date })
        print(String(localized: "\(violationsList.count) violation(s) total."))
        print("")

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
    
    private var missingAirportID: String { .init(localized: "????", comment: "missing airport ID") }
    private var flightFormat: String { .init(localized: "%@ %@ %@ → %@", comment: "flight info string [date, registration, origin, destination]") }
    private var violationFormat: String { .init(localized: "- %@", comment: "violation list item") }

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
                return String(localized: "Flight review not accomplished within prior 24 calendar months", comment: "violation")
            case .noPassengerCurrency:
                return String(localized: "Carried passengers without having completed required takeoffs and landings", comment: "violation")
            case .noNightPassengerCurrency:
                return String(localized: "Carried passengers at night without having completed required takeoffs and landings", comment: "violation")
            case .noIFRCurrency:
                return String(localized: "Flew under IFR without having completed required approaches/holds or IPC", comment: "violation")
            case .noPPC:
                return String(localized: "Flew a type-rated aircraft without having completed a FAR 61.58 check", comment: "violation")
            case .noPPCInType:
                return String(localized: "Flew a type-rated aircraft without having completed a FAR 61.58 check in type", comment: "violation")
        }
    }
}
