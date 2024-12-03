import Foundation

package enum Violation: Codable, Sendable {
    case noFlightReview
    case noPassengerCurrency
    case noNightPassengerCurrency
    case noIFRCurrency
    case noPPC
    case noPPCInType
}

package struct Violations: Codable, Sendable {
    package let flight: Flight
    package let violations: Array<Violation>
}
