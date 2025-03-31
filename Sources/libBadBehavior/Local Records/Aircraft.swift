package struct Aircraft: IdentifiableRecord {

    // MARK: Properties

    package let type: AircraftType
    package let registration: String
    package let weight: Double?
    package let tailwheel: Bool

    // MARK: Computed Properties

    package var id: String { registration }

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

    init(aircraft: CNAircraft,
         typeCodeProperty: KeyPath<CNAircraftType, String?>,
         simTypeProperty: KeyPath<CNAircraftType, String?>,
         simCategoryProperty: KeyPath<CNAircraftType, String?>) {
        type = .init(aircraftType: aircraft.aircraft_aircraftType,
                     typeCodeProperty: typeCodeProperty,
                     simTypeProperty: simTypeProperty,
                     simCategoryProperty: simCategoryProperty)
        registration = aircraft.aircraft_aircraftID
        tailwheel = aircraft.aircraft_tailwheel
        weight = aircraft.aircraft_weight?.doubleValue
    }
}
