import Foundation

protocol DatabaseRecordDebugStringConvertible: CustomDebugStringConvertible {
    var debugIdentifier: String { get }
}

extension DatabaseRecordDebugStringConvertible {
    public var debugDescription: String {
        if let idSelf = self as? any Identifiable {
            return "<\(Self.self) #\(idSelf.id): \(debugIdentifier)>"
        } else {
            return "<\(Self.self): \(debugIdentifier)>"
        }
    }
}

extension Aircraft: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { registration }
}

extension AircraftType: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { type }
}

extension Flight: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { "\(date)" }
}

extension FlightApproaches: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { "flight #\(flightID)" }
}

extension FlightCrew: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { "flight #\(flightID)" }
}

extension FlightPassengers: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { "flight #\(flightID)" }
}

extension Place: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { LID }
}

extension FlightInfo: DatabaseRecordDebugStringConvertible {
    var debugIdentifier: String { "\(date.debugDescription) \(originLID ?? "????")→\(destinationLID ?? "????")" }
}
