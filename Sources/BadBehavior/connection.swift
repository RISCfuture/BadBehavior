import Foundation
import SQLite

class LogTenProXDatabase {
    private let db: Connection

    init(path: String) throws {
        try db = Connection(path)
    }

    // MARK: Loading aircraft

    struct Aircraft {
        let registration: String

        let type: String
        let category: Int
        let `class`: Int?

        let tailwheel: Bool
    }

    func eachAircraft(block: (Aircraft) -> Void) throws {
        let aircraftTable = Table("ZAIRCRAFT")
        let aircraftTypes = Table("ZAIRCRAFTTYPE")

        // common columns
        let primaryKey = Expression<Int>("Z_PK")

        // aircraft columns
        let tailwheel = Expression<Bool?>("ZAIRCRAFT_TAILWHEEL")
        let registration = Expression<String>("ZAIRCRAFT_AIRCRAFTID")
        let aircraftTypeFKey = Expression<Int>("ZAIRCRAFT_AIRCRAFTTYPE")

        // type columns
        let `class` = Expression<Int?>("ZAIRCRAFTTYPE_AIRCRAFTCLASS")
        let category = Expression<Int>("ZAIRCRAFTTYPE_CATEGORY")
        let type = Expression<String>("ZAIRCRAFTTYPE_TYPE")

        let query = aircraftTable
            .select(aircraftTable[registration], category, `class`, tailwheel, type)
            .join(aircraftTypes, on: aircraftTypes[primaryKey] == aircraftTypeFKey)

        for row in try db.prepare(query) {
            let aircraft = Aircraft(registration: row[registration], type: row[type], category: row[category], class: row[`class`], tailwheel: (row[tailwheel] != nil && row[tailwheel]!))
            block(aircraft)
        }
    }

    // MARK: Loading flights

    private static var referenceDate: Date {
        var components = DateComponents()
        components.year = 2001
        components.month = 1
        components.day = 1
        components.timeZone = TimeZone(abbreviation: "UTC")
        return Calendar.current.date(from: components)!
    }

    struct Flight {
        let date: Date
        let airplaneRegistration: String

        let originLID: String?
        let destinationLID: String?

        let remarks: String
        let flightReview: Bool
        let IPC: Bool

        let PICTime: Float
        let actualInstrumentTime: Float
        let nightTime: Float
        let dualReceivedTime: Float
        let soloTime: Float

        let dayLandings: Int
        let nightLandings: Int
        let dayTakeoffs: Int
        let nightTakeoffs: Int
        let fullStops: Int
        let nightFullStops: Int

        let approachesCount: UInt
        let holdsCount: Int
        let hasPassengers: Bool

        let hasSIC: Bool
    }

    func eachFlight(block: (Flight) -> Void) throws {
        let flights = Table("ZFLIGHT")
        let places = Table("ZPLACE")
        let origin = places.alias("origin")
        let destination = places.alias("destination")
        let aircraft = Table("ZAIRCRAFT")
        let approaches = Table("ZFLIGHTAPPROACHES")
        let passengers = Table("ZFLIGHTPASSENGERS")

        // common columns
        let primaryKey = Expression<Int>("Z_PK")

        // flight columns
        let actualInstrumentTime = Expression<Int?>("ZFLIGHT_ACTUALINSTRUMENT")
        let nightFullStops = Expression<Int?>("ZFLIGHT_CUSTOMLANDING5")
        let dayLandings = Expression<Int?>("ZFLIGHT_DAYLANDINGS")
        let dayTakeoffs = Expression<Int?>("ZFLIGHT_DAYTAKEOFFS")
        let holds = Expression<Int?>("ZFLIGHT_HOLDS")
        let nightTime = Expression<Int>("ZFLIGHT_NIGHT")
        let nightLandings = Expression<Int?>("ZFLIGHT_NIGHTLANDINGS")
        let nightTakeoffs = Expression<Int?>("ZFLIGHT_NIGHTTAKEOFFS")
        let PICTime = Expression<Int?>("ZFLIGHT_PIC")
        let flightReview = Expression<Bool>("ZFLIGHT_REVIEW")
        let IPC = Expression<Bool>("ZFLIGHT_INSTRUMENTPROFICIENCYCHECK")
        let aircraftID = Expression<Int>("ZFLIGHT_AIRCRAFT")
        let passengersCount = Expression<Int?>("ZFLIGHT_FLIGHTPAXCOUNT")
        let originID = Expression<Int?>("ZFLIGHT_FROMPLACE")
        let destinationID = Expression<Int?>("ZFLIGHT_TOPLACE")
        let date = Expression<Int>("ZFLIGHT_FLIGHTDATE")
        let remarks = Expression<String>("ZFLIGHT_REMARKS")
        let fullStops = Expression<Int>("ZFLIGHT_FULLSTOPS")
        let dualReceived = Expression<Int?>("ZFLIGHT_DUALRECEIVED")
        let solo = Expression<Int?>("ZFLIGHT_SOLO")
        let SICID = Expression<Int?>("ZFLIGHT_SIC")

        // place columns
        let LID = Expression<String>("ZPLACE_IDENTIFIER")

        // aircraft columns
        let registration = Expression<String>("ZAIRCRAFT_AIRCRAFTID")

        // approaches
        let approachesFlightID = Expression<Int>("ZFLIGHTAPPROACHES_FLIGHT")
        let approach1 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH1")
        let approach2 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH2")
        let approach3 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH3")
        let approach4 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH4")
        let approach5 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH5")
        let approach6 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH6")
        let approach7 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH7")
        let approach8 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH8")
        let approach9 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH9")
        let approach10 = Expression<Int?>("ZFLIGHTAPPROACHES_APPROACH10")

        // passenger columns
        let passengersFlightID = Expression<Int>("ZFLIGHTPASSENGERS_FLIGHT")
        let pax1 = Expression<Int?>("ZFLIGHTPASSENGERS_PAX1")

        let query = flights
            .select(origin[LID], destination[LID], registration,
                    date, remarks, flightReview, IPC,
                    actualInstrumentTime, nightTime, PICTime, dualReceived, solo,
                    nightFullStops, dayLandings, dayTakeoffs, nightLandings, nightTakeoffs, fullStops,
                    holds, passengersCount, SICID,
                    approach1, approach2, approach3, approach4, approach5,
                    approach6, approach7, approach8, approach9, approach10,
                    pax1)
            .join(origin, on: origin[primaryKey] == originID)
            .join(destination, on: destination[primaryKey] == destinationID)
            .join(aircraft, on: aircraftID == aircraft[primaryKey])
            .join(approaches, on: approachesFlightID == flights[primaryKey])
            .join(passengers, on: passengersFlightID == flights[primaryKey])

        for row in try db.prepare(query) {
            let PICTimeHours = Float(row[PICTime] ?? 0)/60.0
            let nightTimeHours = Float(row[nightTime])/60.0
            let actualTimeHours = Float(row[actualInstrumentTime] ?? 0)/60.0
            let dualReceivedTimeHours = Float(row[dualReceived] ?? 0)/60.0
            let soloTimeHours = Float(row[solo] ?? 0)/60.0

            var totalApproaches: UInt = 0
            if row[approach1] != nil { totalApproaches += 1 }
            if row[approach2] != nil { totalApproaches += 1 }
            if row[approach3] != nil { totalApproaches += 1 }
            if row[approach4] != nil { totalApproaches += 1 }
            if row[approach5] != nil { totalApproaches += 1 }
            if row[approach6] != nil { totalApproaches += 1 }
            if row[approach7] != nil { totalApproaches += 1 }
            if row[approach8] != nil { totalApproaches += 1 }
            if row[approach9] != nil { totalApproaches += 1 }
            if row[approach10] != nil { totalApproaches += 1 }

            let parsedDate = Date(timeInterval: Double(row[date]), since: LogTenProXDatabase.referenceDate)

            let flight = Flight(date: parsedDate, airplaneRegistration: row[registration],
                                originLID: row[origin[LID]], destinationLID: row[destination[LID]],
                                remarks: row[remarks], flightReview: row[flightReview], IPC: row[IPC],
                                PICTime: PICTimeHours, actualInstrumentTime: actualTimeHours, nightTime: nightTimeHours, dualReceivedTime: dualReceivedTimeHours, soloTime: soloTimeHours,
                                dayLandings: row[dayLandings] ?? 0, nightLandings: row[nightLandings] ?? 0,
                                dayTakeoffs: row[dayTakeoffs] ?? 0, nightTakeoffs: row[nightTakeoffs] ?? 0,
                                fullStops: row[fullStops],
                                nightFullStops: row[nightFullStops] ?? 0,
                                approachesCount: totalApproaches, holdsCount: row[holds] ?? 0,
                                hasPassengers: (row[pax1] != nil), hasSIC: (row[SICID] != nil))
            block(flight)
        }
    }
}

