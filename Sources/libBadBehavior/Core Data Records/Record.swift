/// A protocol for data records that can be serialized and shared across concurrency contexts.
///
/// All flight-related data types in libBadBehavior conform to this protocol, enabling them to be
/// encoded/decoded (for persistence or transfer) and safely used with Swift concurrency.
package protocol Record: Codable, Sendable {
}

/// A protocol for data records that have a unique identifier.
///
/// Types conforming to this protocol can be compared for equality and used in collections that
/// require hashable elements. The default implementations use the `id` property for equality
/// comparison and hashing.
package protocol IdentifiableRecord: Record, Identifiable, Hashable, Equatable {
}

extension IdentifiableRecord {
  /// Compares two records for equality based on their identifiers.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side record.
  ///   - rhs: The right-hand side record.
  /// - Returns: `true` if both records have the same `id`, `false` otherwise.
  package static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }

  /// Hashes the record using its identifier.
  ///
  /// - Parameter hasher: The hasher to use for combining the record's identifier.
  package func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

/// A protocol for enumeration types used within data records.
///
/// This protocol combines `RawRepresentable`, `Codable`, and `Sendable` for enumerations
/// that represent categorical data (such as aircraft categories or approach types).
protocol RecordEnum: RawRepresentable, Codable, Sendable {}
