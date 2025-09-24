import CoreData
import Foundation

@objc(CNFlightCrew)
final class CNFlightCrew: NSManagedObject {

  // MARK: Managed Properties

  @NSManaged var flightCrew_PIC: CNPerson?
  @NSManaged var flightCrew_SIC: CNPerson?
  @NSManaged var flightCrew_flightEngineer: CNPerson?
  @NSManaged var flightCrew_instructor: CNPerson?
  @NSManaged var flightCrew_student: CNPerson?

  @NSManaged var flightCrew_purser: CNPerson?
  @NSManaged var flightCrew_flightAttendant1: CNPerson?
  @NSManaged var flightCrew_flightAttendant2: CNPerson?
  @NSManaged var flightCrew_flightAttendant3: CNPerson?
  @NSManaged var flightCrew_flightAttendant4: CNPerson?

  @NSManaged var flightCrew_custom1: CNPerson?
  @NSManaged var flightCrew_custom2: CNPerson?
  @NSManaged var flightCrew_custom3: CNPerson?
  @NSManaged var flightCrew_custom4: CNPerson?
  @NSManaged var flightCrew_custom5: CNPerson?
  @NSManaged var flightCrew_custom6: CNPerson?
  @NSManaged var flightCrew_custom7: CNPerson?
  @NSManaged var flightCrew_custom8: CNPerson?
  @NSManaged var flightCrew_custom9: CNPerson?
  @NSManaged var flightCrew_custom10: CNPerson?

  // MARK: Computed Properties

  var flightAttendants: [CNPerson] {
    [
      flightCrew_purser,
      flightCrew_flightAttendant1,
      flightCrew_flightAttendant2,
      flightCrew_flightAttendant3,
      flightCrew_flightAttendant4
    ].compactMap(\.self)
  }
}
