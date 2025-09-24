import CoreData
import Foundation

@objc(CNLogTenCustomizationProperty)
final class CNLogTenCustomizationProperty: NSManagedObject {
  @NSManaged var logTenCustomizationProperty_title: String
  @NSManaged var logTenProperty_key: String

  @nonobjc
  static func fetchRequest(title: String, keyPrefix: String) -> NSFetchRequest<
    CNLogTenCustomizationProperty
  > {
    let request = NSFetchRequest<CNLogTenCustomizationProperty>(
      entityName: "LogTenCustomizationProperty"
    )
    request.predicate = .init(
      format: "logTenCustomizationProperty_title == %@ AND logTenProperty_key BEGINSWITH %@",
      title,
      keyPrefix
    )
    return request
  }
}
