import CoreData
import Foundation

@objc(CNAircraftType)
final class CNAircraftType: NSManagedObject {

  // MARK: Managed Properties

  @NSManaged var aircraftType_type: String
  @NSManaged var aircraftType_category: CNLogTenCustomizationProperty
  @NSManaged var aircraftType_aircraftClass: CNLogTenCustomizationProperty?

  @NSManaged var aircraftType_customAttribute1: String?
  @NSManaged var aircraftType_customAttribute2: String?
  @NSManaged var aircraftType_customAttribute3: String?
  @NSManaged var aircraftType_customAttribute4: String?
  @NSManaged var aircraftType_customAttribute5: String?

  @NSManaged var aircraftType_engineType: CNLogTenCustomizationProperty?
}
