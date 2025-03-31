import Foundation

package struct Person: IdentifiableRecord {

    // MARK: Properties

    package let id: URL
    package let name: String
    package let email: String?
    package let isMe: Bool

    // MARK: Initializers

    init?(person: CNPerson?) {
        guard let person else { return nil }
        id = person.objectID.uriRepresentation()
        name = person.person_name
        email = person.person_email
        isMe = person.person_isMe?.boolValue ?? false
    }
}
