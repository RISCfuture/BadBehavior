import Foundation
import GRDB

struct FlightPassengers {
    // MARK: Properties
    
    var flightID: Int
    var passenger1: Int?
    var passenger2: Int?
    var passenger3: Int?
    var passenger4: Int?
    var passenger5: Int?
    var passenger6: Int?
    var passenger7: Int?
    var passenger8: Int?
    var passenger9: Int?
    var passenger10: Int?
    
    // MARK: Derived Properties
    
    var count: Int {
        var count = 0
        
        if passenger1 != nil { count += 1 }
        if passenger2 != nil { count += 1 }
        if passenger3 != nil { count += 1 }
        if passenger4 != nil { count += 1 }
        if passenger5 != nil { count += 1 }
        if passenger6 != nil { count += 1 }
        if passenger7 != nil { count += 1 }
        if passenger8 != nil { count += 1 }
        if passenger9 != nil { count += 1 }
        if passenger10 != nil { count += 1 }
        
        return count
    }
    
    var isEmpty: Bool { count == 0 }
}

extension FlightPassengers: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case flightID = "ZFLIGHTPASSENGERS_FLIGHT"
        case passenger1 = "ZFLIGHTPASSENGERS_PAX1"
        case passenger2 = "ZFLIGHTPASSENGERS_PAX2"
        case passenger3 = "ZFLIGHTPASSENGERS_PAX3"
        case passenger4 = "ZFLIGHTPASSENGERS_PAX4"
        case passenger5 = "ZFLIGHTPASSENGERS_PAX5"
        case passenger6 = "ZFLIGHTPASSENGERS_PAX6"
        case passenger7 = "ZFLIGHTPASSENGERS_PAX7"
        case passenger8 = "ZFLIGHTPASSENGERS_PAX8"
        case passenger9 = "ZFLIGHTPASSENGERS_PAX9"
        case passenger10 = "ZFLIGHTPASSENGERS_PAX10"
    }
}

extension FlightPassengers: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension FlightPassengers: TableRecord {
    static var databaseTableName: String { "ZFLIGHTPASSENGERS" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let flightForeignKey = ForeignKey([column(for: .flightID)])
    static let flight = belongsTo(Flight.self)
    var flight: QueryInterfaceRequest<Flight> { request(for: Self.flight) }
}
