# ``libBadBehavior``

Core library for reading LogTen Pro logbooks and validating flights against FAR regulations.

@Metadata {
    @DisplayName("libBadBehavior")
}

## Overview

libBadBehavior provides the core functionality for reading LogTen Pro databases and checking flights for FAR Part 61 and 91 violations. This library is used by the BadBehavior command-line tool but can also be integrated into other applications.

The library consists of three main components:

- **Reader**: Reads and parses LogTen Pro Core Data stores
- **Validators**: Check flights against specific FAR requirements
- **Data Models**: Represent flights, aircraft, and violation records

## Topics

### Reading LogTen Data

- ``Reader``
- ``Logbook``
- ``LocalLogbook``

### Flight Records

- ``Flight``
- ``LocalFlight``
- ``FlightBase``
- ``Aircraft``
- ``LocalAircraft``

### Validation

- ``Validator``
- ``Violation``

### Error Handling

- ``Errors``
