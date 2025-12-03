import Foundation

/// Types of FAR violations that can be detected by the validator.
///
/// Each case corresponds to a specific FAR regulation that the flight may have violated.
package enum Violation: Codable, Sendable {
  /// Flight made without a valid flight review per FAR 61.56(c).
  ///
  /// A flight review is required within the preceding 24 calendar months for any pilot
  /// acting as PIC (unless the flight is dual received, a student solo, or a checkride).
  case noFlightReview

  /// Passengers carried without required takeoffs/landings per FAR 61.57(a).
  ///
  /// To carry passengers, the pilot must have made at least 3 takeoffs and landings
  /// within the preceding 90 days in the same category and class of aircraft.
  /// Tailwheel aircraft require full-stop landings.
  case noPassengerCurrency

  /// Night passengers carried without required night takeoffs/landings per FAR 61.57(b).
  ///
  /// To carry passengers at night, the pilot must have made at least 3 takeoffs and
  /// full-stop landings at night within the preceding 90 days.
  case noNightPassengerCurrency

  /// IFR flight made without required instrument currency per FAR 61.57(c).
  ///
  /// To fly IFR, the pilot must have completed within the preceding 6 calendar months:
  /// 6 instrument approaches, holding procedures, and intercepting/tracking courses.
  /// An IPC can restore currency.
  case noIFRCurrency

  /// Type-rated aircraft flown without proficiency check per FAR 61.58(a)(1).
  ///
  /// Pilots of aircraft requiring a type rating must complete a proficiency check
  /// within the preceding 24 calendar months.
  case noPPC

  /// Type-rated aircraft flown without proficiency check in type per FAR 61.58(a)(2).
  ///
  /// The proficiency check must be completed in the same type of aircraft (or an
  /// approved simulator).
  case noPPCInType

  /// NVG operations without required NVG currency per FAR 61.57(f).
  ///
  /// To act as PIC using NVGs, the pilot must have completed within the preceding
  /// 2 calendar months: 3 NVG takeoffs and landings, or a proficiency check.
  case noNVGCurrency

  /// NVG passenger operations without required currency per FAR 61.57(f).
  ///
  /// Additional NVG currency requirements apply when carrying passengers.
  case noNVGPassengerCurrency

  /// More than 8 hours of dual instruction given in 24 hours per FAR 61.195(a).
  ///
  /// A flight instructor may not conduct more than 8 hours of flight training
  /// in any 24-consecutive-hour period.
  case dualGiven8in24

  /// Dual instruction given without required time in type per FAR 61.195(f).
  ///
  /// To give training in a multiengine airplane, helicopter, or powered-lift aircraft,
  /// the instructor must have at least 5 flight hours as PIC in the specific make and model.
  case dualGivenTimeInType
}

/// A container for a flight and its associated violations.
///
/// `Violations` groups all detected violations for a single flight, making it easy
/// to report all issues for a given flight.
package struct Violations: Codable, Sendable {
  /// The flight that has violations.
  package let flight: Flight

  /// The violations detected for this flight.
  package let violations: [Violation]
}
