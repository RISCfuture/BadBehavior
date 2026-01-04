import Foundation

/// Represents a lookback time window for currency calculations.
///
/// FAR regulations define currency requirements using different time units:
/// - Hours (e.g., FAR 61.195(a): 8 hours in 24)
/// - Calendar days (e.g., FAR 61.57(a): 90 days for passenger currency)
/// - Calendar months (e.g., FAR 61.56(c): 24 months for flight review)
enum TimeWindow: Sendable {
  case hours(Int)
  case calendarDays(Int)
  case calendarMonths(Int)

  /// Computes the start date for this window relative to a reference date.
  ///
  /// - Parameter referenceDate: The end of the window (typically the flight being checked).
  /// - Returns: The earliest date included in the window.
  ///
  /// ## Calendar Day Calculation
  /// Calendar days start at midnight. For example, with a 90-day window from March 15,
  /// the window includes all flights from December 15 at 00:00:00.
  ///
  /// ## Calendar Month Calculation
  /// Calendar months start from the first of the month. For example, with a 6-month
  /// window from March 15, the window includes all flights from September 1.
  func startDate(from referenceDate: Date) -> Date {
    switch self {
      case .hours(let hours):
        return Calendar.current.date(byAdding: .hour, value: -hours, to: referenceDate)!

      case .calendarDays(let days):
        var date = Calendar.current.date(byAdding: .day, value: -days, to: referenceDate)!
        date = Calendar.current.date(
          bySettingHour: 0,
          minute: 0,
          second: 0,
          of: date
        )!
        return date

      case .calendarMonths(let months):
        let date = Calendar.current.date(byAdding: .month, value: -months, to: referenceDate)!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.day = 1
        return Calendar.current.date(from: components)!
    }
  }
}
