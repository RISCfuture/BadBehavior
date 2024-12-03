package struct Place: IdentifiableRecord {
    
    // MARK: Properties
    
    package let identifier: String
    package var id: String { identifier }
    package let ICAO: String?
    
    // MARK: Initializers
    
    init?(place: CNPlace?) {
        guard let place else { return nil }
        identifier = place.place_identifier
        ICAO = place.place_icaoid
    }
}
