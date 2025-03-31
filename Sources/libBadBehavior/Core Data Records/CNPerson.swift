import CoreData
import Foundation

@objc(CNPerson)
final class CNPerson: NSManagedObject {

    // MARK: Managed Properties

    @NSManaged var person_name: String
    @NSManaged var person_email: String?
    @NSManaged var person_isMe: NSNumber?

    // MARK: Fetch Request

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CNPerson> {
        let request = NSFetchRequest<CNPerson>(entityName: "Person")
        request.sortDescriptors = [
            .init(keyPath: \Self.person_name, ascending: true)
        ]
        return request
    }
}
