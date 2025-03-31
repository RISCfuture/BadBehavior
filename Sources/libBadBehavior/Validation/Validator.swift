import Foundation

package actor Validator {
    // MARK: Fields

    private static let checkers: [ViolationChecker.Type] = [
        NoFlightReview.self,
        NoPassengerCurrency.self,
        NoNightPassengerCurrency.self,
        NoIFRCurrency.self,
        NoProficiencyCheck.self,
        NoProficiencyCheckInType.self,
        NoNVGCurrency.self,
        NoNVGPassengerCurrency.self,
        DualGiven8In24.self,
        DualGivenTimeInType.self
    ]

    private var flights: [Flight]

    // MARK: Init

    package init(flights: [Flight]) {
        self.flights = flights.sorted(by: { $0.date < $1.date })
    }

    // MARK: Scanner

    package func violations() async throws -> [Violations] {
        return try await withThrowingTaskGroup(of: Violations?.self, returning: Array<Violations>.self) { group in
            let checkers = Self.checkers.map { $0.init(flights: flights) }
            for checker in checkers { try await checker.setup() }

            for flight in self.flights {
                group.addTask {
                    var flightViolations = [Violation]()
                    for checker in checkers {
                        if let violation = try await checker.check(flight: flight) { flightViolations.append(violation) }
                    }

                    if !flightViolations.isEmpty { return Violations(flight: flight, violations: flightViolations) }
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
