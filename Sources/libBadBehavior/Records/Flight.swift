import Foundation
@preconcurrency import GRDB

struct Flight: Identifiable, Sendable {
    var id: Int
    var aircraftID: Int
    var fromPlaceID: Int?
    var toPlaceID: Int?
    
    var date: Int
    
    var PICTime: Int?
    var nightTime: Int?
    var actualInstrumentTime: Int?
    var dualReceivedTime: Int?
    var soloTime: Int?
    
    var dayTakeoffs: Int?
    var dayLandings: Int?
    var nightTakeoffs: Int?
    var nightLandings: Int?
    var fullStopLandings: Int?
    var nightFullStopLandings: Int?
    
    var holds: Int?
    
    var remarks: String?
    var flightReview: Bool
    var IPC: Bool
    var FAR61_58: String?
}

extension Flight: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "Z_PK"
        case aircraftID = "ZFLIGHT_AIRCRAFT"
        case fromPlaceID = "ZFLIGHT_FROMPLACE"
        case toPlaceID = "ZFLIGHT_TOPLACE"
        case date = "ZFLIGHT_FLIGHTDATE"
        case PICTime = "ZFLIGHT_PIC"
        case nightTime = "ZFLIGHT_NIGHT"
        case actualInstrumentTime = "ZFLIGHT_ACTUALINSTRUMENT"
        case dualReceivedTime = "ZFLIGHT_DUALRECEIVED"
        case soloTime = "ZFLIGHT_SOLO"
        case dayTakeoffs = "ZFLIGHT_DAYTAKEOFFS"
        case dayLandings = "ZFLIGHT_DAYLANDINGS"
        case nightTakeoffs = "ZFLIGHT_NIGHTTAKEOFFS"
        case nightLandings = "ZFLIGHT_NIGHTLANDINGS"
        case fullStopLandings = "ZFLIGHT_FULLSTOPS"
        case nightFullStopLandings = "ZFLIGHT_CUSTOMLANDING5"
        case holds = "ZFLIGHT_HOLDS"
        case flightReview = "ZFLIGHT_REVIEW"
        case IPC = "ZFLIGHT_INSTRUMENTPROFICIENCYCHECK"
        case remarks = "ZFLIGHT_REMARKS"
        case FAR61_58 = "ZFLIGHT_CUSTOMNOTE1"
    }
}

extension Flight: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension Flight: TableRecord {
    static var databaseTableName: String { "ZFLIGHT" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let aircraftForeignKey = ForeignKey([column(for: .aircraftID)])
    static let aircraft = belongsTo(Aircraft.self, using: aircraftForeignKey).forKey(FlightInfo.CodingKeys.aircraft)
    var aircraft: QueryInterfaceRequest<Aircraft> { request(for: Self.aircraft) }
    
    static let aircraftType = hasOne(AircraftType.self, through: aircraft, using: Aircraft.aircraftType).forKey(FlightInfo.CodingKeys.aircraftType)
    var aircraftType: QueryInterfaceRequest<AircraftType> { request(for: Self.aircraftType) }
    
    static let originForeignKey = ForeignKey([column(for: .fromPlaceID)])
    static let origin = belongsTo(Place.self, key: CodingKeys.fromPlaceID.rawValue, using: originForeignKey).forKey(FlightInfo.CodingKeys.origin)
    var origin: QueryInterfaceRequest<Place> { request(for: Self.origin) }
    
    static let destinationForeignKey = ForeignKey([column(for: .toPlaceID)])
    static let destination = belongsTo(Place.self,  key: CodingKeys.toPlaceID.rawValue, using: destinationForeignKey).forKey(FlightInfo.CodingKeys.destination)
    var destination: QueryInterfaceRequest<Place> { request(for: Self.destination) }
    
    static let approaches = hasOne(FlightApproaches.self, using: FlightApproaches.flightForeignKey).forKey(FlightInfo.CodingKeys.approaches)
    var approaches: QueryInterfaceRequest<FlightApproaches> { request(for: Self.approaches) }
    
    static let crew = hasOne(FlightCrew.self, using: FlightCrew.flightForeignKey).forKey(FlightInfo.CodingKeys.crew)
    var crew: QueryInterfaceRequest<FlightCrew> { request(for: Self.crew) }
    
    static let passengers = hasOne(FlightPassengers.self, using: FlightPassengers.flightForeignKey).forKey(FlightInfo.CodingKeys.passengers)
    var passengers: QueryInterfaceRequest<FlightPassengers> { request(for: Self.passengers) }
}
