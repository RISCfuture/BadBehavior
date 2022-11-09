import Foundation

extension String {
    var presence: String? { isEmpty ? nil : self }
}
