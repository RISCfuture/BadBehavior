import Foundation
import libBadBehavior

/// Protocol for generating violation report output.
protocol OutputGenerator {
  // periphery:ignore - protocol requirement; both conformers read it (Text/JSONOutputGenerator), but Periphery doesn't link the witness reads to the requirement
  /// The output stream for the violation report.
  var outputStream: any TextOutputStream { get set }

  /// Called before processing begins. Implementations may print a status message to stdout.
  func printProcessingMessage()

  /// Generates and writes the violation report to the output stream.
  /// - Parameter violationsList: The list of violations to output.
  func generate(_ violationsList: [Violations]) throws
}

/// A TextOutputStream that writes to stdout.
struct StdoutOutputStream: TextOutputStream {
  mutating func write(_ string: String) {
    print(string, terminator: "")
  }
}
