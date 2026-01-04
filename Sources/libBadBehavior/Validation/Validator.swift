import Foundation

/// Validates flights against FAR Part 61 and 91 currency requirements.
///
/// The `Validator` actor processes a collection of flights and identifies potential
/// regulatory violations. It uses Swift Concurrency to efficiently check each flight
/// against all applicable rules in parallel.
///
/// ## Usage
///
/// ```swift
/// let validator = Validator(flights: flights)
/// let violations = try await validator.violations()
/// ```
///
/// ## Checked Regulations
///
/// The validator checks for violations of:
/// - **FAR 61.56(c)**: Flight review currency (24 calendar months)
/// - **FAR 61.57(a)**: Passenger currency (takeoffs/landings in 90 days)
/// - **FAR 61.57(b)**: Night passenger currency
/// - **FAR 61.57(c)**: IFR currency (6 approaches + hold in 6 months)
/// - **FAR 61.55(b)**: SIC currency for type-rated aircraft
/// - **FAR 61.57(f)**: NVG currency and passenger currency
/// - **FAR 61.58**: Proficiency checks for type-rated aircraft
/// - **FAR 61.195(a)**: CFI 8-hour daily limit
/// - **FAR 61.195(f)**: CFI time-in-type requirements
package actor Validator {
  // MARK: Fields

  private static let checkers: [ViolationChecker.Type] = [
    NoFlightReview.self,
    NoPassengerCurrency.self,
    NoNightPassengerCurrency.self,
    NoIFRCurrency.self,
    NoSICCurrency.self,
    NoProficiencyCheck.self,
    NoProficiencyCheckInType.self,
    NoNVGCurrency.self,
    NoNVGPassengerCurrency.self,
    DualGiven8In24.self,
    DualGivenTimeInType.self
  ]

  private let flightIndex: FlightIndex

  // MARK: Init

  /// Creates a validator for the given flights.
  ///
  /// The flights are automatically sorted chronologically for proper currency tracking.
  /// Earlier flights are checked first to establish a currency baseline.
  ///
  /// - Parameter flights: The flights to validate.
  package init(flights: [Flight]) {
    let sortedFlights = flights.sorted(by: { $0.date < $1.date })
    self.flightIndex = FlightIndex(flights: sortedFlights)
  }

  // MARK: Scanner

  /// Validates all flights and returns any violations found.
  ///
  /// Each flight is checked against all 11 violation checkers. The validation process:
  /// 1. Initializes all checkers with the flight index
  /// 2. Calls `setup()` on each checker for any expensive pre-computation
  /// 3. Checks each flight in parallel using a task group
  /// 4. Collects and returns only flights that have violations
  ///
  /// - Returns: An array of ``Violations`` containing only flights with detected issues.
  ///   Flights without violations are not included in the results.
  ///
  /// - Throws: Errors from individual violation checkers if they encounter invalid data.
  package func violations() async throws -> [Violations] {
    return try await withThrowingTaskGroup(of: Violations?.self, returning: Array<Violations>.self)
    { group in
      let checkers = Self.checkers.map { $0.init(flightIndex: flightIndex) }
      for checker in checkers { try await checker.setup() }

      for flight in flightIndex.flights {
        group.addTask {
          var flightViolations = [Violation]()
          for checker in checkers {
            if let violation = try await checker.check(flight: flight) {
              flightViolations.append(violation)
            }
          }

          if !flightViolations.isEmpty {
            return Violations(flight: flight, violations: flightViolations)
          }
          return nil
        }
      }

      var violations = [Violations]()
      for try await case let v? in group {
        violations.append(v)
      }
      return violations
    }
  }
}
