import Foundation

package enum Violation: Codable, Sendable {
  case noFlightReview
  case noPassengerCurrency
  case noNightPassengerCurrency
  case noIFRCurrency
  case noPPC
  case noPPCInType
  case noNVGCurrency
  case noNVGPassengerCurrency
  case dualGiven8in24
  case dualGivenTimeInType
}

package struct Violations: Codable, Sendable {
  package let flight: Flight
  package let violations: [Violation]
}
