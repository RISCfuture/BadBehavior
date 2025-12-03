import Foundation

extension String {
  /// Returns `nil` if the string is empty, otherwise returns the string itself.
  ///
  /// This is useful for converting empty strings to `nil` for optional handling.
  var presence: String? { isEmpty ? nil : self }

  /// Indicates whether the string contains any characters.
  ///
  /// Equivalent to `!isEmpty`.
  var isPresent: Bool { !isEmpty }
}
