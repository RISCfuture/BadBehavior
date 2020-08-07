import Foundation

class CommandLineTool {
    private static let logbookSubpath = "Containers/com.coradine.LogTenProX/Data/Documents/LogTenProData/LogTenCoreDataStore.sql"

    private var logbookConnection: LogTenProXDatabase!

    var aircraft: Array<Aircraft>
    var flights: Array<Flight>

    init() {
        aircraft = []
        flights = []
    }

    func run() throws {
        try connectToLogbook()
        try loadAircraft()
        try loadFlights()
        try findBadBehavior()
    }

    // MARK: Logbook

    private func logbookPath() throws -> String {
        let URLs = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        guard URLs.count == 1 else { throw Errors.cantFindLogbook(path: nil) }

        return URLs[0].appendingPathComponent(CommandLineTool.logbookSubpath).path
    }

    private func connectToLogbook() throws {
        let path = try logbookPath()
        guard FileManager.default.fileExists(atPath: path) else { throw Errors.cantFindLogbook(path: path) }
        logbookConnection = try LogTenProXDatabase(path: path)
    }

    // MARK: Aircraft

    private func loadAircraft() throws {
        try logbookConnection.eachAircraft { aircraftRow in
            guard aircraftRow.`class` != nil else { return }
            aircraft.append(convertAircraftRowToAircraft(aircraftRow))
        }
    }

    private static let categories = [
        210: Aircraft.Category.airplane
    ]

    private static let classes = [
        321: Aircraft.Class.singleEngineLand,
        146: Aircraft.Class.singleEngineSea,
        680: Aircraft.Class.multiEngineLand
    ]

    private func convertAircraftRowToAircraft(_ row: LogTenProXDatabase.Aircraft) -> Aircraft {
        return Aircraft(registration: row.registration,
                        type: row.type,
                        category: CommandLineTool.categories[row.category]!,
                        class: CommandLineTool.classes[row.`class`!]!,
                        tailwheel: row.tailwheel)
    }

    // MARK: Flights

    private func loadFlights() throws {
        try logbookConnection.eachFlight { flightRow in
            guard let flight = convertFlightRowToFlight(flightRow) else { return }
            flights.append(flight)
        }
        flights.sort { $0.date < $1.date }
    }

    private func convertFlightRowToFlight(_ row: LogTenProXDatabase.Flight) -> Flight? {
        guard let a = aircraft.first(where: { $0.registration == row.airplaneRegistration }) else { return nil }

        let hasSafetyPilot = (row.hasSIC && row.remarks != nil && row.remarks!.localizedCaseInsensitiveContains("safety"))

        return Flight(aircraft: a,
                      date: row.date,
                      remarks: row.remarks,
                      origin: row.originLID,
                      destination: row.destinationLID,
                      PIC: row.PICTime > 0,
                      trainingFlight: row.dualReceivedTime >= 0.1,
                      passengers: row.hasPassengers,
                      night: row.nightTime >= 0.1,
                      IFR: (row.actualInstrumentTime >= 0.1 || row.approachesCount > 0),
                      studentSolo: row.soloTime >= 0.1,
                      safetyPilotOnboard: hasSafetyPilot,
                      totalTakeoffs: UInt(row.nightTakeoffs + row.dayTakeoffs),
                      totalLandings: UInt(row.nightLandings + row.dayLandings),
                      nightTakeoffs: UInt(row.nightTakeoffs),
                      nightLandings: UInt(row.nightLandings),
                      fullStopLandings: UInt(row.fullStops),
                      nightFullStopLandings: UInt(row.nightFullStops),
                      approaches: row.approachesCount,
                      holds: UInt(row.holdsCount),
                      BFR: row.flightReview,
                      IPC: row.IPC)
    }

    // MARK: Discrepancies

    private static var datePrinter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }

    private func findBadBehavior() throws {
        for flight in flights {
            let checker = Checker(flight, caller: self)
            let BFRCurrency = checker.outOfBFRCurrency()
            let paxCurrency = checker.outOfPassengerCurrency()
            let nightPaxCurrency = checker.outOfNightPassengerCurrency()
            let IFRCurrency = checker.outOfIFRCurrency()

            if (!BFRCurrency && !paxCurrency && !nightPaxCurrency && !IFRCurrency) { continue }

            print("\(CommandLineTool.datePrinter.string(from: flight.date)) \(flight.aircraft.registration) \(flight.origin ?? "???") → \(flight.destination ?? "???")")
            if (flight.remarks != nil) { print(flight.remarks!) }
            print("")

            if BFRCurrency { print(" - Flight review not accomplished within prior 24 calendar months") }
            if paxCurrency { print(" - Carried passengers without having completed required takeoffs and landings") }
            if nightPaxCurrency { print(" - Carried passengers at night without having completed required takeoffs and landings") }
            if IFRCurrency { print(" - Flew under IFR without having completed required approaches/holds or IPC") }

            print("")
            print("---------------------------")
            print("")
        }
    }

    // MARK: Errors

    enum Errors: Error {
        case cantFindLogbook(path: String?)
    }
}
