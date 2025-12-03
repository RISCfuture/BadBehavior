# Reading LogTen Data

Learn how to use the Reader class to extract flight data from your LogTen Pro logbook.

## Overview

The `Reader` class provides an interface to LogTen Pro's Core Data store. It handles the complexity of Core Data setup, custom field mapping, and data conversion.

## Initializing the Reader

Create a Reader by providing paths to the LogTen data store and managed object model:

```swift
let reader = try await Reader(
    storeURL: logTenDatabaseURL,
    modelURL: managedObjectModelURL
)
```

The Reader opens the database in read-only mode, ensuring your logbook data is never modified.

### Default Locations

LogTen Pro stores its data at predictable locations:

- **Database file:**
  `~/Library/Group Containers/group.com.coradine.LogTenPro/LogTenProData_.../LogTenCoreDataStore.sql`

- **Managed object model:**
  `/Applications/LogTen.app/Contents/Resources/CNLogBookDocument.momd`

## Reading Flights

Call `read()` to fetch all flights from the logbook:

```swift
let flights = try await reader.read()
```

This returns an array of `Flight` objects, each containing:
- Flight date and times
- Aircraft information
- Crew members and passengers
- Approaches flown
- Takeoffs and landings
- Currency-relevant flags (flight review, IPC, checkride, etc.)

## Data Model Relationships

The Reader automatically resolves relationships between entities:

```
Flight
  |-- Aircraft
  |     +-- AircraftType
  |-- Person (PIC, SIC, Safety Pilot)
  |-- Person[] (Passengers)
  |-- Place (From, To)
  +-- Approach[]
        +-- Place
```

## Error Handling

The Reader may throw `Errors` if:
- The Core Data store cannot be opened
- Required custom fields are missing
- The LogTen version is incompatible

```swift
do {
    let reader = try await Reader(storeURL: storeURL, modelURL: modelURL)
} catch Errors.couldntCreateStore(let path) {
    print("Could not open LogTen database at \(path)")
} catch Errors.missingProperty(let property, let model) {
    print("Missing required field '\(property)' in \(model)")
}
```
