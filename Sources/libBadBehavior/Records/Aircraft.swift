import Foundation
@preconcurrency import GRDB

struct Aircraft: Identifiable, Sendable {
    var id: Int
    var aircraftTypeID: String
    var registration: String
    
    var weight: Double?
    var tailwheel: Bool?
}

extension Aircraft: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "Z_PK"
        case aircraftTypeID = "ZAIRCRAFT_AIRCRAFTTYPE"
        case registration = "ZAIRCRAFT_AIRCRAFTID"
        case weight = "ZAIRCRAFT_WEIGHT"
        case tailwheel = "ZAIRCRAFT_TAILWHEEL"
    }
}

extension Aircraft: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension Aircraft: TableRecord {
    static var databaseTableName: String { "ZAIRCRAFT" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let aircraftTypeForeignKey = ForeignKey([column(for: .aircraftTypeID)])
    static let aircraftType = belongsTo(AircraftType.self, using: aircraftTypeForeignKey)
    var aircraftType: QueryInterfaceRequest<AircraftType> { request(for: Self.aircraftType) }
    
    static let flights = hasMany(Flight.self, using: Flight.aircraftForeignKey)
    var flights: QueryInterfaceRequest<Flight> { request(for: Self.flights) }
}
