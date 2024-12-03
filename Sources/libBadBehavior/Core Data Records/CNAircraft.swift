import Foundation
import CoreData

@objc(CNAircraft)
final class CNAircraft: NSManagedObject {
    
    // MARK: Fetch Request
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CNAircraft> {
        let request = NSFetchRequest<CNAircraft>(entityName: "Aircraft")
        request.sortDescriptors = [
            .init(keyPath: \CNAircraft.aircraft_aircraftID, ascending: true)
        ]
        request.includesSubentities = true
        return request
    }
    
    // MARK: Managed Properties
    
    @NSManaged var aircraft_aircraftType: CNAircraftType
    @NSManaged var aircraft_aircraftID: String
    
    @NSManaged var aircraft_weight: NSNumber?
    @NSManaged var aircraft_tailwheel: Bool
    
    @NSManaged var aircraft_customAttribute1: Bool
    @NSManaged var aircraft_customAttribute2: Bool
    @NSManaged var aircraft_customAttribute3: Bool
    @NSManaged var aircraft_customAttribute4: Bool
    @NSManaged var aircraft_customAttribute5: Bool
}
