import Foundation

/// A person record from the LogTen Pro logbook.
///
/// `Person` represents crew members (PIC, SIC, safety pilot) or passengers associated
/// with flights. The ``isMe`` property indicates whether this person is the logbook owner.
package struct Person: IdentifiableRecord {

  // MARK: Properties

  /// The unique identifier for this person, derived from its Core Data object ID.
  package let id: URL

  /// The person's name.
  package let name: String

  /// The person's email address, if recorded.
  package let email: String?

  /// Whether this person is the logbook owner (i.e., "me").
  package let isMe: Bool

  // MARK: Initializers

  /// Creates a Person from a Core Data CNPerson object.
  ///
  /// - Parameter person: The Core Data person object, or `nil`.
  /// - Returns: A `Person` instance, or `nil` if the input was `nil`.
  init?(person: CNPerson?) {
    guard let person else { return nil }
    id = person.objectID.uriRepresentation()
    name = person.person_name
    email = person.person_email
    isMe = person.person_isMe?.boolValue ?? false
  }
}
