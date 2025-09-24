import CoreData
import Foundation

@objc(CNFlightApproaches)
final class CNFlightApproaches: NSManagedObject {

  // MARK: Managed Properties

  @NSManaged private var flightApproaches_approach1: CNApproach?
  @NSManaged private var flightApproaches_approach2: CNApproach?
  @NSManaged private var flightApproaches_approach3: CNApproach?
  @NSManaged private var flightApproaches_approach4: CNApproach?
  @NSManaged private var flightApproaches_approach5: CNApproach?
  @NSManaged private var flightApproaches_approach6: CNApproach?
  @NSManaged private var flightApproaches_approach7: CNApproach?
  @NSManaged private var flightApproaches_approach8: CNApproach?
  @NSManaged private var flightApproaches_approach9: CNApproach?
  @NSManaged private var flightApproaches_approach10: CNApproach?

  // MARK: Computed Properties

  var approaches: [CNApproach] {
    [
      flightApproaches_approach1,
      flightApproaches_approach2,
      flightApproaches_approach3,
      flightApproaches_approach4,
      flightApproaches_approach5,
      flightApproaches_approach6,
      flightApproaches_approach7,
      flightApproaches_approach8,
      flightApproaches_approach9,
      flightApproaches_approach10
    ].compactMap(\.self)
  }
}
