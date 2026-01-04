import Foundation
import libBadBehavior

/// A single flight with its violations for JSON output.
private struct JSONFlightViolation: Codable {
  let date: Date
  let registration: String?
  let from: String?
  let to: String?
  let violations: [String]
}

/// Machine-readable JSON output structure.
private struct JSONViolationsOutput: Codable {
  let totalViolations: Int
  let flights: [JSONFlightViolation]
}

/// Generates machine-readable JSON output for violation reports.
struct JSONOutputGenerator: OutputGenerator {
  var outputStream: any TextOutputStream = StdoutOutputStream()

  func printProcessingMessage() {
    // JSON output suppresses status messages
  }

  func generate(_ violationsList: [Violations]) throws {
    let output = JSONViolationsOutput(
      totalViolations: violationsList.count,
      flights: violationsList.map { violations in
        JSONFlightViolation(
          date: violations.flight.date,
          registration: violations.flight.aircraft?.registration,
          from: violations.flight.from?.identifier,
          to: violations.flight.to?.identifier,
          violations: violations.violations.map { String(describing: $0) }
        )
      }
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let data = try encoder.encode(output)
    if let jsonString = String(data: data, encoding: .utf8) {
      var stream = outputStream
      // Workaround for Swift compiler bug #84395: must provide all parameters explicitly
      print(jsonString, separator: "", terminator: "\n", to: &stream)
    }
  }
}
