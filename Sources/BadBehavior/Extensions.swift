import Foundation

extension AsyncSequence {
  /// Collects all elements of the async sequence into an array.
  ///
  /// - Returns: An array containing all elements of the sequence.
  func collect() async rethrows -> [Element] {
    try await reduce(into: [Element]()) { $0.append($1) }
  }
}
