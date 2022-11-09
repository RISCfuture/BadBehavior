import Foundation
import GRDB

struct FlightApproaches {
    // MARK: Properties
    
    var flightID: Int
    var approach1: Int?
    var approach2: Int?
    var approach3: Int?
    var approach4: Int?
    var approach5: Int?
    var approach6: Int?
    var approach7: Int?
    var approach8: Int?
    var approach9: Int?
    var approach10: Int?
    
    // MARK: Derived Properties
    
    var count: Int {
        var count = 0
        
        if approach1 != nil { count += 1 }
        if approach2 != nil { count += 1 }
        if approach3 != nil { count += 1 }
        if approach4 != nil { count += 1 }
        if approach5 != nil { count += 1 }
        if approach6 != nil { count += 1 }
        if approach7 != nil { count += 1 }
        if approach8 != nil { count += 1 }
        if approach9 != nil { count += 1 }
        if approach10 != nil { count += 1 }
        
        return count
    }
    
    var isEmpty: Bool { count == 0 }
}

extension FlightApproaches: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case flightID = "ZFLIGHTAPPROACHES_FLIGHT"
        case approach1 = "ZFLIGHTAPPROACHES_APPROACH1"
        case approach2 = "ZFLIGHTAPPROACHES_APPROACH2"
        case approach3 = "ZFLIGHTAPPROACHES_APPROACH3"
        case approach4 = "ZFLIGHTAPPROACHES_APPROACH4"
        case approach5 = "ZFLIGHTAPPROACHES_APPROACH5"
        case approach6 = "ZFLIGHTAPPROACHES_APPROACH6"
        case approach7 = "ZFLIGHTAPPROACHES_APPROACH7"
        case approach8 = "ZFLIGHTAPPROACHES_APPROACH8"
        case approach9 = "ZFLIGHTAPPROACHES_APPROACH9"
        case approach10 = "ZFLIGHTAPPROACHES_APPROACH10"
    }
}

extension FlightApproaches: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension FlightApproaches: TableRecord {
    static var databaseTableName: String { "ZFLIGHTAPPROACHES" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let flightForeignKey = ForeignKey([column(for: .flightID)])
    static let flight = belongsTo(Flight.self)
    var flight: QueryInterfaceRequest<Flight> { request(for: Self.flight) }
}
