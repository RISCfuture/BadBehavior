import Foundation
import GRDB

struct CustomizationProperty: Identifiable {
    var id: Int
    var defaultTitle: String
}

extension CustomizationProperty: Codable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "Z_PK"
        case defaultTitle = "ZLOGTENCUSTOMIZATIONPROPERTY_DEFAULTTITLE"
    }
}

extension CustomizationProperty: FetchableRecord, PersistableRecord {
    static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .custom({ CodingKeys(rawValue: $0)! }) }
    static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .custom({ $0.stringValue }) }
    
    static func column(for key: CodingKeys) -> Column {
        Column(key)
    }
}

extension CustomizationProperty: TableRecord {
    static var databaseTableName: String { "ZLOGTENCUSTOMIZATIONPROPERTY" }
    static var databaseSelection: [SQLSelectable] { return CodingKeys.allCases.map { column(for: $0) } }
}
