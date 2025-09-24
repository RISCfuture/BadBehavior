import CoreData
import Foundation

private let nightFullStopField = "Night Full Stops"
private let proficiencyField = "FAR 61.58"
private let checkrideField = "Checkride"

private let safetyPilotField = "Safety Pilot"
private let examinerField = "Examiner"

package class Reader {
  private let container: NSPersistentContainer

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

  package func read() async throws -> [Flight] {
    let context = container.newBackgroundContext()
    return try await context.perform {
      let aircraft = try self.fetchAircraft(context: context)
      return try self.fetchFlights(context: context, aircraft: aircraft)
    }
  }
}
