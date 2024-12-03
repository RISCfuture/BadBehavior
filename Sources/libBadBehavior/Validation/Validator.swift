import Foundation

package actor Validator {
    // MARK: Fields
    
    private var flights: Array<Flight>
    private static let checkers: Array<ViolationChecker.Type> = [
        NoFlightReview.self,
        NoPassengerCurrency.self,
        NoNightPassengerCurrency.self,
        NoIFRCurrency.self,
        NoProficiencyCheck.self,
        NoProficiencyCheckInType.self
    ]
    
    // MARK: Init
    
    package init(flights: Array<Flight>) {
        self.flights = flights.sorted(by: { $0.date < $1.date })
    }

    // MARK: Scanner
    
    package func violations() async throws -> Array<Violations> {
        return try await withThrowingTaskGroup(of: Violations?.self, returning: Array<Violations>.self) { group in
            let checkers = Self.checkers.map { $0.init(flights: flights) }
            for checker in checkers { try await checker.setup() }
            
            for flight in self.flights {
                group.addTask {
                    var flightViolations = Array<Violation>()
                    for checker in checkers {
                        if let violation = try await checker.check(flight: flight) { flightViolations.append(violation) }
                    }
                    
                    if !flightViolations.isEmpty { return Violations(flight: flight, violations: flightViolations) }
                    else { return nil }
                }
            }
            
            var violations = Array<Violations>()
            for try await v in group {
                if let v = v { violations.append(v) }
            }
            return violations
        }
    }
}
