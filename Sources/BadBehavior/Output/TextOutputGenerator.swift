import Foundation
import libBadBehavior

/// Generates human-readable text output for violation reports.
struct TextOutputGenerator: OutputGenerator {
  var outputStream: any TextOutputStream = StdoutOutputStream()

  private var datePrinter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }

  func printProcessingMessage() {
    print(String(localized: "Processing…"))
  }

  func generate(_ violationsList: [Violations]) {
    var stream = outputStream
    // Workaround for Swift compiler bug #84395: must provide all parameters explicitly
    print(
      String(localized: "\(violationsList.count) violations total."),
      separator: "",
      terminator: "\n",
      to: &stream
    )
    print("", separator: "", terminator: "\n", to: &stream)

    for violations in violationsList {
      print(string(from: violations.flight), separator: "", terminator: "\n", to: &stream)
      if let remarks = violations.flight.remarks {
        print(remarks, separator: "", terminator: "\n", to: &stream)
      }
      print("", separator: "", terminator: "\n", to: &stream)

      for violation in violations.violations {
        print(
          String(localized: "- \(string(from: violation))"),
          separator: "",
          terminator: "\n",
          to: &stream
        )
      }

      print("", separator: "", terminator: "\n", to: &stream)
      print("", separator: "", terminator: "\n", to: &stream)
    }
  }

  private func string(from flight: Flight) -> String {
    let date = datePrinter.string(from: flight.date)
    let registration = flight.aircraft?.registration ?? String(localized: "????")
    let origin = flight.from?.identifier ?? String(localized: "????")
    let destination = flight.to?.identifier ?? String(localized: "????")

    return String(localized: "\(date) \(registration) \(origin) → \(destination)")
  }

  private func string(from violation: Violation) -> String {
    switch violation {
      case .noFlightReview:
        return String(
          localized: "Flight review not accomplished within prior 24 calendar months [61.56(c)]"
        )
      case .noPassengerCurrency:
        return String(
          localized:
            "Carried passengers without having completed required takeoffs and landings [61.57(a)]"
        )
      case .noNightPassengerCurrency:
        return String(
          localized:
            "Carried passengers at night without having completed required takeoffs and landings [61.57(b)]"
        )
      case .noIFRCurrency:
        return String(
          localized:
            "Flew under IFR without having completed required approaches/holds or IPC [61.57(c)]"
        )
      case .noPPC:
        return String(
          localized:
            "Flew a type-rated aircraft without having completed a FAR 61.58 check [61.58(a)(1)]"
        )
      case .noPPCInType:
        return String(
          localized:
            "Flew a type-rated aircraft without having completed a FAR 61.58 check in type [61.58(a)(2)]"
        )
      case .noNVGCurrency:
        return String(
          localized:
            "Made a takeoff or landing under NVGs without having the required NVG takeoffs and landings or proificiency checks [61.57(f)]"
        )
      case .noNVGPassengerCurrency:
        return String(
          localized:
            "Made a takeoff or landing under NVGs with passengers without having the required NVG takeoffs and landings or proificiency checks [61.57(f)]"
        )
      case .dualGiven8in24:
        return String(
          localized: "Exceeded maximum 8 hours of dual given in a 24-hour period [61.195(a)]"
        )
      case .dualGivenTimeInType:
        return String(
          localized:
            "Gave training in a multi-engine, helicopter, or powered-lift aircraft without having 5 hours in type [61.195(f)]"
        )
      case .noSICCurrency:
        return String(
          localized:
            "Acted as SIC in type-rated aircraft without required takeoffs and landings [61.55(b)]"
        )
    }
  }
}
