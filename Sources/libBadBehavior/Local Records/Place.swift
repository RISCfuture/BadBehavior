/// An airport or other location from the LogTen Pro logbook.
///
/// `Place` represents departure and arrival airports, as well as approach locations.
/// The identifier is typically the FAA airport code (e.g., "SFO") or ICAO code.
package struct Place: IdentifiableRecord {

  // MARK: Properties

  /// The location identifier (typically the airport code).
  package let identifier: String

  /// The unique identifier for this place (same as ``identifier``).
  package var id: String { identifier }

  /// The ICAO airport code, if available (e.g., "KSFO").
  package let ICAO: String?

  // MARK: Initializers

  /// Creates a Place from a Core Data CNPlace object.
  ///
  /// - Parameter place: The Core Data place object, or `nil`.
  /// - Returns: A `Place` instance, or `nil` if the input was `nil`.
  init?(place: CNPlace?) {
    guard let place else { return nil }
    identifier = place.place_identifier
    ICAO = place.place_icaoid
  }
}
