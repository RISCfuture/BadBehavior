import Foundation
import GRDB

struct AircraftType: Identifiable {
    var id: Int
    
    var type: String
    var category: Int
    var `class`: Int?
    var engineTypeID: Int?
    
    var simType: String?
    var simAircraftType: String?
    var simAircraftCategoryClass: String?
}

extension AircraftType: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "Z_PK"
        case type = "ZAIRCRAFTTYPE_TYPE"
        case category = "ZAIRCRAFTTYPE_CATEGORY"
        case `class` = "ZAIRCRAFTTYPE_AIRCRAFTCLASS"
        case simType = "ZAIRCRAFTTYPE_CUSTOMATTRIBUTE1"
        case simAircraftType = "ZAIRCRAFTTYPE_CUSTOMATTRIBUTE2"
        case simAircraftCategoryClass = "ZAIRCRAFTTYPE_CUSTOMATTRIBUTE3"
        case engineTypeID = "ZAIRCRAFTTYPE_ENGINETYPE"
    }
}

extension AircraftType: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension AircraftType: TableRecord {
    static var databaseTableName: String { "ZAIRCRAFTTYPE" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
    
    static let aircraft = hasMany(Aircraft.self, using: Aircraft.aircraftTypeForeignKey)
    var aircraft: QueryInterfaceRequest<Aircraft> { request(for: Self.aircraft) }
    
    static let engineTypeForeignKey = ForeignKey([column(for: .engineTypeID)])
    static let engineType = belongsTo(CustomizationProperty.self, using: engineTypeForeignKey)
    var engineType: QueryInterfaceRequest<CustomizationProperty> { request(for: Self.engineType) }
}
