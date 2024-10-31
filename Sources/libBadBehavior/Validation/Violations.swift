import Foundation

public enum Violation: Codable, Sendable {
    case noFlightReview
    case noPassengerCurrency
    case noNightPassengerCurrency
    case noIFRCurrency
    case noPPC
    case noPPCInType
}

public struct Violations: Codable, Sendable {
    public let flight: FlightInfo
    public let violations: Array<Violation>
}
