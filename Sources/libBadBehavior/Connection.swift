import Foundation
import GRDB

public class Connection {
    
    // MARK: Initializers
    
    public init(logbookPath: String? = nil) throws {
        self.logbookPath = try logbookPath ?? Self.defaultLogbookPath()
        dbPool = try DatabasePool(path: self.logbookPath)
    }
    
    // MARK: Logbook
    
    private static let logbookSubpath = "Group Containers/group.com.coradine.LogTenPro/LogTenProData_6583aa561ec1cc91302449b5/LogTenCoreDataStore.sql"
    
    public static func defaultLogbookPath() throws -> String {
        let URLs = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        guard URLs.count == 1 else { throw Errors.noLibraryDirectory }
        
        return URLs[0].appendingPathComponent(logbookSubpath).path
    }
    
    private let logbookPath: String
    
    // MARK: Database
    
    private let dbPool: DatabasePool
    
    public func eachFlight() -> AsyncThrowingStream<FlightInfo, Error> {
        AsyncThrowingStream { continuation in
            dbPool.asyncRead { result in
                do {
                    let db = try result.get()
                    
                    let cursor = try Flight
                        .including(required: Flight.aircraft)
                        .including(required: Flight.aircraftType)
                        .including(optional: Flight.approaches)
                        .including(optional: Flight.crew)
                        .including(optional: Flight.passengers)
                        .including(optional: Flight.origin)
                        .including(optional: Flight.destination)
                        .asRequest(of: FlightInfo.self)
                        .fetchCursor(db)
                    
                    while let record = try cursor.next() {
                        continuation.yield(record)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
