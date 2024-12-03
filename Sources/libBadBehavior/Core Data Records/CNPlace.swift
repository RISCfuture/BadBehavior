import Foundation
import CoreData

@objc(CNPlace)
final class CNPlace: NSManagedObject {
    
    // MARK: Managed Columns
    
    @NSManaged var place_identifier: String
    @NSManaged var place_icaoid: String?
}
