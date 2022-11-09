import Foundation

public enum Violation: Codable {
    case noFlightReview
    case noPassengerCurrency
    case noNightPassengerCurrency
    case noIFRCurrency
    case noPPC
    case noPPCInType
}

public struct Violations: Codable {
    public let flight: FlightInfo
    public let violations: Array<Violation>
}
