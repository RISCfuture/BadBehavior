import Foundation

/// Errors that can occur when reading LogTen Pro data or processing flight records.
///
/// These errors typically indicate configuration issues with the LogTen Pro installation
/// or missing custom fields that are required for currency validation.
package enum Errors: Swift.Error {
  /// The Core Data store could not be created or opened.
  ///
  /// This usually indicates that LogTen Pro is not installed, the database file is missing
  /// or corrupted, or the version is incompatible with this tool.
  ///
  /// - Parameter path: The URL of the database file that could not be opened.
  case couldntCreateStore(path: URL)

  /// A required custom property is missing from the LogTen Pro configuration.
  ///
  /// LogTen Pro allows custom fields to be added to various record types. This error
  /// indicates that an expected custom field (such as "Night Full Stops" or "FAR 61.58")
  /// has not been configured.
  ///
  /// - Parameters:
  ///   - property: The name of the missing property.
  ///   - model: The model type where the property was expected (e.g., "Flight", "Aircraft Type").
  case missingProperty(_ property: String, model: String)

  /// The aircraft class is not valid for the specified category.
  ///
  /// For example, "Helicopter" is only valid for the "Rotorcraft" category, not "Airplane".
  ///
  /// - Parameters:
  ///   - class: The invalid aircraft class.
  ///   - forCategory: The aircraft category that doesn't support this class.
  case invalidClass(_ `class`: AircraftType.Class, forCategory: AircraftType.Category)

  /// The aircraft type is missing a required class specification.
  ///
  /// Certain aircraft categories (such as Airplane) require a class to be specified
  /// (e.g., Single-Engine Land, Multi-Engine Sea).
  ///
  /// - Parameter type: The aircraft type identifier that is missing a class.
  case missingClass(type: String)

  /// A simulator aircraft type is missing the required Sim Type field.
  ///
  /// Simulator entries must specify their type (BATD, AATD, FTD, or FFS) to properly
  /// determine what currency they can satisfy.
  ///
  /// - Parameter type: The simulator aircraft type that is missing the Sim Type field.
  case missingSimulatorType(type: String)
}

extension Errors: LocalizedError {
  package var errorDescription: String? {
    switch self {
      case .couldntCreateStore(let path):
        return String(localized: "Couldn’t create Core Data store for “\(path.lastPathComponent)”")
      case .missingProperty:
        return String(localized: "A required property is missing")
      case .invalidClass:
        return String(localized: "Aircraft category/class pair is invalid")
      case .missingClass(let type):
        return String(localized: "Missing aircraft class for aircraft type “\(type)”")
      case .missingSimulatorType(let type):
        return String(localized: "Missing Sim Type for aircraft type “\(type)”")
    }
  }

  package var failureReason: String? {
    switch self {
      case .couldntCreateStore:
        return String(
          localized: "The LogTen Pro data either doesn’t exist, is invalid, or is a newer version."
        )
      case let .missingProperty(property, model):
        return String(localized: "\(model) must have a property named “\(property)”.")
      case let .invalidClass(`class`, category):
        return String(
          localized:
            "“\(`class`.localizedDescription)” is not a valid aircraft class for category “\(category.localizedDescription)”."
        )
      case .missingClass:
        return String(localized: "Aircraft category requires a class.")
      case .missingSimulatorType:
        return String(localized: "Simulator requires a Sim Type entry.")
    }
  }

  package var recoverySuggestion: String? {
    switch self {
      case .couldntCreateStore:
        return String(
          localized:
            "Install LogTen Pro if it is not installed, or check that its version is compatible with this tool."
        )
      case let .missingProperty(property, model):
        return String(localized: "Add a property called “\(property)” to \(model).")
      case .invalidClass:
        return String(localized: "Modify the aircraft to correct its category and class.")
      case .missingClass:
        return String(localized: "Add the aircraft class to the Aircraft record.")
      case .missingSimulatorType:
        return String(localized: "Add the Sim Type entry to the Aircraft record for the simulator.")
    }
  }
}
