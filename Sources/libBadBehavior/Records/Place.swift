import Foundation
import GRDB

struct Place {
    var id: Int
    var LID: String
}

extension Place: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "Z_PK"
        case LID = "ZPLACE_IDENTIFIER"
    }
}

extension Place: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension Place: TableRecord {
    static var databaseTableName: String { "ZPLACE" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let originatingFlights = hasMany(Flight.self, using: Flight.originForeignKey)
    var originatingFlights: QueryInterfaceRequest<Flight> { request(for: Self.originatingFlights) }
    
    static let terminatingFLights = hasMany(Flight.self, using: Flight.destinationForeignKey)
    var terminatingFlights: QueryInterfaceRequest<Flight> { request(for: Self.terminatingFLights) }
}
