package protocol Record: Codable, Sendable {
}

package protocol IdentifiableRecord: Record, Identifiable, Hashable, Equatable {
}

extension IdentifiableRecord {
  package static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }

  package func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

protocol RecordEnum: RawRepresentable, Codable, Sendable {}
