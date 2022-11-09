import Foundation
import GRDB

struct FlightCrew {
    var flightID: Int
    var PIC: Int?
    var safetyPilot: Int?
}

extension FlightCrew: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case flightID = "ZFLIGHTCREW_FLIGHT"
        case PIC = "ZFLIGHTCREW_PIC"
        case safetyPilot = "ZFLIGHTCREW_CUSTOM1"
    }
}

extension FlightCrew: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension FlightCrew: TableRecord {
    static var databaseTableName: String { "ZFLIGHTCREW" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let flightForeignKey = ForeignKey([column(for: .flightID)])
    static let flight = belongsTo(Flight.self)
    var flight: QueryInterfaceRequest<Flight> { request(for: Self.flight) }
}
