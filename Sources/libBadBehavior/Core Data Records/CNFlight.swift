import CoreData
import Foundation

@objc(CNFlight)
final class CNFlight: NSManagedObject {

    // MARK: Managed Properties

    @NSManaged var flight_aircraft: CNAircraft?
    @NSManaged var flight_flightApproaches: CNFlightApproaches?
    @NSManaged var flight_flightCrew: CNFlightCrew?
    @NSManaged var flight_flightPassengers: CNFlightPassengers?

    @NSManaged var flight_flightDate: Date

    @NSManaged var flight_fromPlace: CNPlace?
    @NSManaged var flight_toPlace: CNPlace?

    @NSManaged var flight_pic: NSNumber?
    @NSManaged var flight_solo: NSNumber?
    @NSManaged var flight_night: NSNumber?
    @NSManaged var flight_dualReceived: NSNumber?
    @NSManaged var flight_dualGiven: NSNumber?
    @NSManaged var flight_actualInstrument: NSNumber?
    @NSManaged var flight_nightVisionGoggle: NSNumber?

    @NSManaged var flight_dayTakeoffs: NSNumber?
    @NSManaged var flight_nightTakeoffs: NSNumber?
    @NSManaged var flight_dayLandings: NSNumber?
    @NSManaged var flight_nightLandings: NSNumber?
    @NSManaged var flight_fullStops: NSNumber?
    @NSManaged var flight_customLanding1: NSNumber?
    @NSManaged var flight_customLanding2: NSNumber?
    @NSManaged var flight_customLanding3: NSNumber?
    @NSManaged var flight_customLanding4: NSNumber?
    @NSManaged var flight_customLanding5: NSNumber?
    @NSManaged var flight_customLanding6: NSNumber?
    @NSManaged var flight_customLanding7: NSNumber?
    @NSManaged var flight_customLanding8: NSNumber?
    @NSManaged var flight_customLanding9: NSNumber?
    @NSManaged var flight_customLanding10: NSNumber?
    @NSManaged var flight_nightVisionGoggleTakeoffs: NSNumber?
    @NSManaged var flight_nightVisionGoggleLandings: NSNumber?

    @NSManaged var flight_holds: NSNumber?
    @NSManaged var flight_review: NSNumber?
    @NSManaged var flight_instrumentProficiencyCheck: NSNumber?
    @NSManaged var flight_customNote1: String?
    @NSManaged var flight_customNote2: String?
    @NSManaged var flight_customNote3: String?
    @NSManaged var flight_customNote4: String?
    @NSManaged var flight_customNote5: String?
    @NSManaged var flight_customNote6: String?
    @NSManaged var flight_customNote7: String?
    @NSManaged var flight_customNote8: String?
    @NSManaged var flight_customNote9: String?
    @NSManaged var flight_customNote10: String?
    @NSManaged var flight_remarks: String?

    // MARK: Fetch Request

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CNFlight> {
        let request = NSFetchRequest<CNFlight>(entityName: "Flight")
        request.includesSubentities = true
        request.sortDescriptors = [
            .init(keyPath: \CNFlight.flight_flightDate, ascending: true) // swiftlint:disable:this prefer_self_in_static_references
        ]
        return request
    }
}
