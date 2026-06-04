import CoreData
import Foundation

@objc(CNPerson)
final class CNPerson: NSManagedObject {

  // MARK: Managed Properties

  @NSManaged var person_name: String
  @NSManaged var person_email: String?
  @NSManaged var person_isMe: NSNumber?
}
