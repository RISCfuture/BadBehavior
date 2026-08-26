import ArgumentParser
import Foundation
import libBadBehavior

// NOTE: This tool uploads its results to the FAA Enforcement Division. Please
// ensure you have an active connection to the Internet before executing it.

/// Output format for violation reports.
enum OutputFormat: String, ExpressibleByArgument, CaseIterable {
  case text
  case json

  /// Returns the appropriate output generator for this format.
  var generator: OutputGenerator {
    switch self {
      case .text: TextOutputGenerator()
      case .json: JSONOutputGenerator()
    }
  }
}

/// Command-line tool that scans a LogTen Pro logbook for FAR Part 91 violations.
///
/// BadBehavior reads flight data from LogTen Pro for Mac and validates each flight
/// against FAR Part 61 and 91 currency requirements. It reports any flights that
/// may have violated regulations.
///
/// ## Usage
///
/// Run without arguments to scan the LogTen Pro logbook found on this Mac:
/// ```
/// BadBehavior
/// ```
///
/// Specify custom file locations:
/// ```
/// BadBehavior --logten-file /path/to/LogTenCoreDataStore.sql \
///             --logten-managed-object-model /path/to/CNLogBookDocument.momd
/// ```
@main
struct BadBehavior: AsyncParsableCommand {

  static let configuration = CommandConfiguration(
    abstract:
      "Scans your LogTen for Mac logbook, looking for any flights that may have been contrary to FAR part 91 regulations.",
    discussion: """
      In particular, it attempts to locate the following flights:

      * Flights made outside of the 24-month window following a BFR.
      * Flights with passengers made without the required takeoffs and landings within
      the previous 90 days (including special tailwheel requirements).
      * Night flights with passengers made without the required night takeoffs and
      landings within the previous 90 days (including special tailwheel
      requirements).
      * IFR flights made with fewer than six approaches and one hold in the preceding
      six months (and no IPC accomplished).
      * Flights in type-rated aircraft without the required FAR 61.58 check having
      been completed.

      It prints to the terminal a list of such flights and the reasons they are out of
      currency.
      """
  )

  private static let logtenGroupContainerPath =
    "Library/Group Containers/group.com.coradine.LogTenPro"
  private static let dataDirectoryPrefix = "LogTenProData_"
  private static let dataStoreFilename = "LogTenCoreDataStore.sql"
  private static let managedObjectModelPath = "LogTen.app/Contents/Resources/CNLogBookDocument.momd"

  private static var logtenGroupContainerURL: URL {
    FileManager.default.homeDirectoryForCurrentUser.appending(path: logtenGroupContainerPath)
  }

  private static var managedObjectModelURL: URL {
    .applicationDirectory.appending(path: managedObjectModelPath)
  }

  // MARK: Arguments

  /// Path to the LogTen Pro SQLite database file.
  ///
  /// When not given, the logbook is located by searching
  /// `~/Library/Group Containers/group.com.coradine.LogTenPro` for the most recently
  /// modified `LogTenCoreDataStore.sql`.
  @Option(
    help: "The LogTenCoreDataStore.sql file containing the logbook entries.",
    completion: .file(extensions: ["sql"]),
    transform: { .init(filePath: $0, directoryHint: .notDirectory) }
  )
  var logtenFile: URL?

  /// Path to the LogTen Pro Core Data managed object model.
  ///
  /// The default path is the standard LogTen Pro application bundle location:
  /// `/Applications/LogTen.app/Contents/Resources/CNLogBookDocument.momd`
  @Option(
    help: "The location of the LogTen Pro managed object model file.",
    completion: .file(extensions: ["momd"]),
    transform: { .init(filePath: $0, directoryHint: .isDirectory) }
  )
  var logtenManagedObjectModel = Self.managedObjectModelURL

  /// The output format for the violation report.
  ///
  /// Use `text` for human-readable output (default) or `json` for machine-readable output.
  @Option(help: "Output format: text or json.")
  var format: OutputFormat = .text

  // MARK: Locating the logbook

  /// LogTen Pro suffixes its data directory with an installation-specific
  /// identifier, so the logbook is located by searching the group container
  /// rather than by assuming a fixed path.
  private static func locateDataStore() throws -> URL {
    guard let dataStore = dataStoresByRecency().first else {
      throw Errors.couldntFindDataStore(directory: logtenGroupContainerURL)
    }
    return dataStore
  }

  private static func dataStoresByRecency() -> [URL] {
    let dataDirectories =
      (try? FileManager.default.contentsOfDirectory(
        at: logtenGroupContainerURL,
        includingPropertiesForKeys: nil
      )) ?? []

    return
      dataDirectories
      .filter { $0.lastPathComponent.hasPrefix(dataDirectoryPrefix) }
      .map { $0.appending(path: dataStoreFilename) }
      .filter { FileManager.default.fileExists(atPath: $0.path(percentEncoded: false)) }
      .sorted { modificationDate(of: $0) > modificationDate(of: $1) }
  }

  private static func modificationDate(of url: URL) -> Date {
    (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate)
      ?? .distantPast
  }

  // MARK: Main

  /// Executes the violation scan.
  ///
  /// This method:
  /// 1. Reads all flights from the LogTen Pro database
  /// 2. Validates each flight against FAR currency requirements
  /// 3. Prints violations grouped by flight to stdout
  mutating func run() async throws {
    let outputGenerator = format.generator
    outputGenerator.printProcessingMessage()

    let storeURL = try logtenFile ?? Self.locateDataStore()
    let reader = try await Reader(storeURL: storeURL, modelURL: logtenManagedObjectModel)

    let flights = try await reader.read()
    let validator = Validator(flights: flights)

    let violationsList = try await validator.violations().sorted(by: {
      $0.flight.date < $1.flight.date
    })

    try outputGenerator.generate(violationsList)
  }
}
