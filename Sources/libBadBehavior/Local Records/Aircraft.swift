/// An aircraft from the LogTen Pro logbook.
///
/// `Aircraft` represents a specific aircraft identified by its registration (tail number).
/// Each aircraft has an associated ``AircraftType`` that describes its category, class,
/// and engine configuration.
package struct Aircraft: IdentifiableRecord {

  // MARK: Properties

  /// The aircraft type information (category, class, engine type, etc.).
  package let type: AircraftType

  /// The aircraft registration number (tail number).
  package let registration: String

  /// The maximum gross weight of the aircraft in pounds, if known.
  ///
  /// Used to determine if the aircraft requires a type rating (≥12,500 lbs).
  package let weight: Double?

  /// Whether the aircraft is a conventional gear (tailwheel) aircraft.
  ///
  /// Tailwheel aircraft have additional landing requirements for passenger currency
  /// per FAR 61.57(a)(1)(ii).
  package let tailwheel: Bool

  // MARK: Computed Properties

  /// The unique identifier for this aircraft (its registration number).
  package var id: String { registration }

  /// Whether this aircraft requires a type rating to operate.
  ///
  /// An aircraft requires a type rating if any of the following are true:
  /// - It is a powered-lift aircraft
  /// - It has a turbine engine (turboshaft, turboprop, turbofan, turbojet, or ramjet)
  /// - Its maximum gross weight is 12,500 pounds or more
  ///
  /// Aircraft requiring type ratings are subject to FAR 61.58 proficiency check requirements.
  package var typeRatingRequired: Bool {
    if type.category == .poweredLift { return true }
    switch type.engineType {
      case .turboshaft, .turboprop, .turbofan, .turbine, .ramjet, .jet:
        return true
      default: break
    }

    guard let weight else { return false }
    return weight >= 12500
  }

  // MARK: Initializers

  init(
    aircraft: CNAircraft,
    typeCodeProperty: KeyPath<CNAircraftType, String?>,
    simTypeProperty: KeyPath<CNAircraftType, String?>,
    simCategoryProperty: KeyPath<CNAircraftType, String?>
  ) {
    type = .init(
      aircraftType: aircraft.aircraft_aircraftType,
      typeCodeProperty: typeCodeProperty,
      simTypeProperty: simTypeProperty,
      simCategoryProperty: simCategoryProperty
    )
    registration = aircraft.aircraft_aircraftID
    tailwheel = aircraft.aircraft_tailwheel
    weight = aircraft.aircraft_weight?.doubleValue
  }
}
