import CoreData
import Foundation

private let nightFullStopField = "Night Full Stops"
private let proficiencyField = "FAR 61.58"
private let checkrideField = "Checkride"

private let safetyPilotField = "Safety Pilot"
private let examinerField = "Examiner"

/// Reads flight data from a LogTen Pro for Mac Core Data store.
///
/// The `Reader` class provides access to the LogTen Pro SQLite database, extracting flight
/// records and their associated data (aircraft, crew, approaches, etc.) into Swift-native
/// structures suitable for analysis and validation.
///
/// ## Usage
///
/// ```swift
/// let reader = try await Reader(
///     storeURL: logTenDatabaseURL,
///     modelURL: managedObjectModelURL
/// )
/// let flights = try await reader.read()
/// ```
///
/// ## Database Access
///
/// The database is opened in **read-only mode** to ensure your LogTen Pro logbook is never
/// modified. The reader also configures SQLite to use DELETE journal mode for optimal
/// read performance.
///
/// ## Custom Field Requirements
///
/// LogTen Pro supports custom fields that this reader depends on for complete data extraction.
/// The following custom fields must be configured in LogTen Pro:
///
/// - **Flight Custom Landings**: "Night Full Stops"
/// - **Flight Custom Notes**: "FAR 61.58", "Checkride", "FAR 61.31(k)"
/// - **Flight Crew Custom Roles**: "Safety Pilot", "Examiner"
/// - **Aircraft Type Custom Fields**: "Type Code", "Sim Type", "Sim A/C Cat"
///
/// If any required custom field is missing, an ``Errors/missingProperty(_:model:)`` error
/// will be thrown.
package class Reader {
  private let container: NSPersistentContainer

  /// Creates a new Reader connected to a LogTen Pro database.
  ///
  /// This initializer opens the specified LogTen Pro Core Data store in read-only mode.
  /// The database is never modified by this reader.
  ///
  /// - Parameters:
  ///   - storeURL: The URL to the `LogTenCoreDataStore.sql` file. The default location is
  ///     `~/Library/Group Containers/group.com.coradine.LogTenPro/LogTenProData_.../LogTenCoreDataStore.sql`
  ///   - modelURL: The URL to the `CNLogBookDocument.momd` directory containing the Core Data
  ///     managed object model. The default location is
  ///     `/Applications/LogTen.app/Contents/Resources/CNLogBookDocument.momd`
  ///
  /// - Throws: ``Errors/couldntCreateStore(path:)`` if the database or model cannot be opened.
  package init(storeURL: URL, modelURL: URL) async throws {
    guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
      throw Errors.couldntCreateStore(path: modelURL)
    }
    container = NSPersistentContainer(name: "LogTen Pro", managedObjectModel: managedObjectModel)

    let store = NSPersistentStoreDescription(url: storeURL)
    store.setOption(NSNumber(value: true), forKey: NSReadOnlyPersistentStoreOption)
    store.setOption(["journal_mode": "DELETE"] as NSObject, forKey: NSSQLitePragmasOption)

    try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<Void, Swift.Error>) in
      container.persistentStoreDescriptions = [store]
      container.loadPersistentStores { _, error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: ())
        }
      }
    }
  }

  /// Reads all flights from the LogTen Pro logbook.
  ///
  /// This method fetches all aircraft and flights from the Core Data store, resolving
  /// relationships and mapping LogTen Pro's custom fields to their proper values.
  ///
  /// The returned flights include:
  /// - Aircraft information with type details
  /// - Crew members (PIC, SIC, safety pilot)
  /// - Passengers
  /// - Origin and destination airports
  /// - Approaches flown
  /// - All flight times and operation counts
  /// - Currency-relevant flags (flight review, IPC, checkride, etc.)
  ///
  /// - Returns: An array of ``Flight`` objects representing all flights in the logbook.
  ///   Flights without a valid aircraft association are excluded.
  ///
  /// - Throws: ``Errors/missingProperty(_:model:)`` if required custom fields are not
  ///   configured in LogTen Pro.
  package func read() async throws -> [Flight] {
    let context = container.newBackgroundContext()
    return try await context.perform {
      let aircraft = try self.fetchAircraft(context: context)
      return try self.fetchFlights(context: context, aircraft: aircraft)
    }
  }
}
