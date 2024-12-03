import Foundation
import CoreData

@objc(CNLogTenCustomizationProperty)
final class CNLogTenCustomizationProperty: NSManagedObject {
    @nonobjc class func fetchRequest(title: String, keyPrefix: String) -> NSFetchRequest<CNLogTenCustomizationProperty> {
        let request = NSFetchRequest<CNLogTenCustomizationProperty>(entityName: "LogTenCustomizationProperty")
        request.predicate = .init(format: "logTenCustomizationProperty_title == %@ AND logTenProperty_key BEGINSWITH %@",
                                  title, keyPrefix)
        return request
    }
    
    @NSManaged var logTenCustomizationProperty_title: String
    @NSManaged var logTenProperty_key: String
}
