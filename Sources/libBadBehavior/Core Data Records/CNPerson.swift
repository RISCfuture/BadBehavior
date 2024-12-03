import Foundation
import CoreData

@objc(CNPerson)
final class CNPerson: NSManagedObject {
    
    // MARK: Fetch Request
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<CNPerson> {
        let request = NSFetchRequest<CNPerson>(entityName: "Person")
        request.sortDescriptors = [
            .init(keyPath: \CNPerson.person_name, ascending: true)
        ]
        return request
    }
    
    // MARK: Managed Properties
    
    @NSManaged var person_name: String
    @NSManaged var person_email: String?
    @NSManaged var person_isMe: NSNumber?
}
