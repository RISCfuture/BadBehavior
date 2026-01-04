import CoreData

private let typeCodeField = "Type Code"
private let simTypeField = "Sim Type"
private let simCategoryField = "Sim A/C Cat"

extension Reader {
  /// Fetches all aircraft from the LogTen Pro database.
  ///
  /// This method retrieves all aircraft records and converts them to ``Aircraft`` instances,
  /// resolving custom property mappings for type code, simulator type, and simulator category.
  ///
  /// - Parameter context: The Core Data managed object context to use for fetching.
  /// - Returns: An array of ``Aircraft`` instances.
  /// - Throws: ``Errors/missingProperty(_:model:)`` if required custom fields are not configured.
  static func fetchAircraft(context: NSManagedObjectContext) throws -> [Aircraft] {
    let request = CNAircraft.fetchRequest()
    let aircraft = try context.fetch(request)

    let typeCodeProperty = try aircraftTypeCustomAttribute(for: typeCodeField, context: context)
    let simTypeProperty = try aircraftTypeCustomAttribute(for: simTypeField, context: context)
    let simCategoryProperty = try aircraftTypeCustomAttribute(
      for: simCategoryField,
      context: context
    )

    return aircraft.map { aircraft in
      .init(
        aircraft: aircraft,
        typeCodeProperty: typeCodeProperty,
        simTypeProperty: simTypeProperty,
        simCategoryProperty: simCategoryProperty
      )
    }
  }

  private static func aircraftTypeCustomAttribute(
    for title: String,
    context: NSManagedObjectContext
  )
    throws -> KeyPath<CNAircraftType, String?>
  {
    let request = CNLogTenCustomizationProperty.fetchRequest(
      title: title,
      keyPrefix: "aircraftType_customAttribute"
    )
    let result = try context.fetch(request)
    guard result.count == 1, let property = result.first else {
      throw Errors.missingProperty(title, model: "Aircraft Type")
    }
    switch property.logTenProperty_key {
      case "aircraftType_customAttribute1": return \.aircraftType_customAttribute1
      case "aircraftType_customAttribute2": return \.aircraftType_customAttribute2
      case "aircraftType_customAttribute3": return \.aircraftType_customAttribute3
      case "aircraftType_customAttribute4": return \.aircraftType_customAttribute4
      case "aircraftType_customAttribute5": return \.aircraftType_customAttribute5
      default: preconditionFailure("Unknown custom attribute \(property.logTenProperty_key)")
    }
  }

  private static func aircraftCustomAttribute(for title: String, context: NSManagedObjectContext)
    throws
    -> KeyPath<CNAircraft, Bool>
  {
    let request = CNLogTenCustomizationProperty.fetchRequest(
      title: title,
      keyPrefix: "aircraft_customAttribute"
    )
    let result = try context.fetch(request)
    guard result.count == 1, let property = result.first else {
      throw Errors.missingProperty(title, model: "Aircraft")
    }
    switch property.logTenProperty_key {
      case "aircraft_customAttribute1": return \.aircraft_customAttribute1
      case "aircraft_customAttribute2": return \.aircraft_customAttribute2
      case "aircraft_customAttribute3": return \.aircraft_customAttribute3
      case "aircraft_customAttribute4": return \.aircraft_customAttribute4
      case "aircraft_customAttribute5": return \.aircraft_customAttribute5
      default: preconditionFailure("Unknown custom attribute \(property.logTenProperty_key)")
    }
  }
}
