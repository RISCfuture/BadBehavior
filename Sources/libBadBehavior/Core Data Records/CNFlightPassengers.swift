import Foundation
import CoreData

@objc(CNFlightPassengers)
final class CNFlightPassengers: NSManagedObject {
    
    // MARK: Managed Properties
    
    @NSManaged private var flightPassengers_pax1: CNPerson?
    @NSManaged private var flightPassengers_pax2: CNPerson?
    @NSManaged private var flightPassengers_pax3: CNPerson?
    @NSManaged private var flightPassengers_pax4: CNPerson?
    @NSManaged private var flightPassengers_pax5: CNPerson?
    @NSManaged private var flightPassengers_pax6: CNPerson?
    @NSManaged private var flightPassengers_pax7: CNPerson?
    @NSManaged private var flightPassengers_pax8: CNPerson?
    @NSManaged private var flightPassengers_pax9: CNPerson?
    @NSManaged private var flightPassengers_pax10: CNPerson?
    @NSManaged private var flightPassengers_pax11: CNPerson?
    @NSManaged private var flightPassengers_pax12: CNPerson?
    @NSManaged private var flightPassengers_pax13: CNPerson?
    @NSManaged private var flightPassengers_pax14: CNPerson?
    @NSManaged private var flightPassengers_pax15: CNPerson?
    @NSManaged private var flightPassengers_pax16: CNPerson?
    @NSManaged private var flightPassengers_pax17: CNPerson?
    @NSManaged private var flightPassengers_pax18: CNPerson?
    @NSManaged private var flightPassengers_pax19: CNPerson?
    @NSManaged private var flightPassengers_pax20: CNPerson?
    
    // MARK: Computed Properties
    
    var passengers: Array<CNPerson> {
        [
            flightPassengers_pax1,
            flightPassengers_pax2,
            flightPassengers_pax3,
            flightPassengers_pax4,
            flightPassengers_pax5,
            flightPassengers_pax6,
            flightPassengers_pax7,
            flightPassengers_pax8,
            flightPassengers_pax9,
            flightPassengers_pax10,
            flightPassengers_pax11,
            flightPassengers_pax12,
            flightPassengers_pax13,
            flightPassengers_pax14,
            flightPassengers_pax15,
            flightPassengers_pax16,
            flightPassengers_pax17,
            flightPassengers_pax18,
            flightPassengers_pax19,
            flightPassengers_pax20
        ].compactMap(\.self)
    }
}
