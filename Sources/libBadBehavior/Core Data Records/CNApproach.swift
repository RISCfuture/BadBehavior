import CoreData
import Foundation

@objc(CNApproach)
final class CNApproach: NSManagedObject {

    // MARK: Managed Properties

    @NSManaged var approach_place: CNPlace?
    @NSManaged var approach_type: String?
    @NSManaged var approach_comment: String?
    @NSManaged var approach_quantity: NSNumber?
}
