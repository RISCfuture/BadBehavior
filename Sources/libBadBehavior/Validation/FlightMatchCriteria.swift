import Foundation

/// Encapsulates aircraft matching rules for currency checks.
///
/// FAR regulations require currency to be established in the same category, class,
/// and sometimes type of aircraft. This type consolidates the matching logic,
/// including special handling for Full Flight Simulators (FFS).
///
/// ## FFS Simulator Handling
///
/// When a past flight was in an FFS simulator, it counts toward currency for the
/// aircraft type being simulated. For example, a CRJ FFS session counts toward
/// CRJ currency.
struct FlightMatchCriteria: Sendable {
  /// The flight being checked for violations.
  let referenceFlight: Flight

  /// Whether to require matching aircraft category.
  let matchCategory: Bool

  /// Whether to require matching aircraft class.
  let matchClass: Bool

  /// Whether to require matching type for type-rated aircraft.
  let matchTypeIfRequired: Bool

  /// Creates criteria that matches any flight (no restrictions).
  static func none(for flight: Flight) -> Self {
    Self(
      referenceFlight: flight,
      matchCategory: false,
      matchClass: false,
      matchTypeIfRequired: false
    )
  }

  /// Creates criteria for category-only matching.
  static func category(for flight: Flight) -> Self {
    Self(
      referenceFlight: flight,
      matchCategory: true,
      matchClass: false,
      matchTypeIfRequired: false
    )
  }

  /// Creates criteria for full category/class/type matching.
  static func full(for flight: Flight) -> Self {
    Self(
      referenceFlight: flight,
      matchCategory: true,
      matchClass: true,
      matchTypeIfRequired: true
    )
  }

  /// Checks if a candidate flight matches the criteria for the reference flight.
  ///
  /// - Parameter candidate: A historical flight to compare against.
  /// - Returns: `true` if the candidate matches all required criteria.
  func matches(_ candidate: Flight) -> Bool {
    if matchCategory && !matchesCategory(candidate) { return false }
    if matchClass && !matchesClass(candidate) { return false }
    if matchTypeIfRequired && !matchesType(candidate) { return false }
    return true
  }

  // MARK: - Private Matching Methods

  /// Checks if the candidate flight is in the same aircraft category.
  ///
  /// Handles simulator logic: FFS flights count toward the simulated aircraft's category.
  private func matchesCategory(_ candidate: Flight) -> Bool {
    guard let currentAircraft = referenceFlight.aircraft,
      let candidateAircraft = candidate.aircraft
    else { return false }

    let currentCategory = currentAircraft.type.category
    let candidateCategory = candidateAircraft.type.category

    // Simulators match everything for the reference flight
    if currentCategory == .simulator { return true }

    // Direct category match
    if currentCategory == candidateCategory { return true }

    // FFS simulator counts toward the simulated category
    if candidateCategory == .simulator && candidateAircraft.type.simType == .FFS {
      return candidateAircraft.type.simCategory == currentCategory
    }

    return false
  }

  /// Checks if the candidate flight is in the same aircraft class.
  ///
  /// Handles simulator logic: FFS flights count toward the simulated aircraft's class.
  private func matchesClass(_ candidate: Flight) -> Bool {
    guard let currentAircraft = referenceFlight.aircraft,
      let candidateAircraft = candidate.aircraft
    else { return false }

    let currentClass = currentAircraft.type.class
    let candidateClass = candidateAircraft.type.class
    let candidateCategory = candidateAircraft.type.category

    // Direct class match
    if currentClass == candidateClass { return true }

    // FFS simulator counts toward the simulated class
    if candidateCategory == .simulator && candidateAircraft.type.simType == .FFS {
      return candidateAircraft.type.simClass == currentClass
    }

    return false
  }

  /// Checks if the candidate flight is in the same aircraft type.
  ///
  /// This is only checked when the reference aircraft requires a type rating.
  /// Handles simulator logic: FFS flights count toward the simulated aircraft's type.
  private func matchesType(_ candidate: Flight) -> Bool {
    guard let currentAircraft = referenceFlight.aircraft,
      let candidateAircraft = candidate.aircraft
    else { return false }

    // If no type rating required, always matches
    guard currentAircraft.typeRatingRequired else { return true }

    // Direct type match
    if currentAircraft.type.type == candidateAircraft.type.type { return true }

    // FFS simulator counts toward the simulated type
    if candidateAircraft.type.category == .simulator && candidateAircraft.type.simType == .FFS {
      return candidateAircraft.type.type == currentAircraft.type.type
    }

    return false
  }
}
