import Foundation

/// A flight record from the LogTen Pro logbook.
///
/// `Flight` contains all the information about a single flight, including times, crew,
/// approaches, and currency-relevant flags. Flight times are stored in minutes internally
/// but can be accessed as hours via computed properties.
///
/// ## Currency-Relevant Properties
///
/// Several properties are specifically used for FAR currency calculations:
///
/// - ``isFlightReview``: Indicates a flight review per FAR 61.56
/// - ``isIPC``: Indicates an instrument proficiency check per FAR 61.57(d)
/// - ``isCheckride``: Indicates a practical test (checkride)
/// - ``isRecurrent``: Indicates a FAR 61.58 proficiency check
/// - ``isNVGProficiencyCheck``: Indicates a FAR 61.31(k) NVG proficiency check
package struct Flight: IdentifiableRecord {

  // MARK: Properties

  /// The unique identifier for this flight, derived from its Core Data object ID.
  package let id: URL

  /// The aircraft used for this flight.
  package let aircraft: Aircraft?

  /// The instrument approaches flown during this flight.
  package let approaches: [Approach]

  /// The departure airport.
  package let from: Place?

  /// The arrival airport.
  package let to: Place?

  /// The date of the flight.
  package let date: Date

  /// The pilot in command for this flight.
  package let PIC: Person?

  /// The second in command for this flight.
  package let SIC: Person?

  /// The safety pilot, if one was aboard (for simulated instrument flight).
  package let safetyPilot: Person?

  /// The passengers on this flight.
  package let passengers: [Person]

  /// Pilot-in-command time logged, in minutes.
  package let PICTime: UInt

  /// Night flight time logged, in minutes.
  package let nightTime: UInt

  /// Actual instrument time logged, in minutes.
  package let actualInstrumentTime: UInt

  /// Dual instruction given time, in minutes (for CFIs).
  package let dualGivenTime: UInt

  /// Dual instruction received time, in minutes.
  package let dualReceivedTime: UInt

  /// Solo flight time, in minutes (indicates student pilot solo).
  package let soloTime: UInt

  /// Night vision goggle (NVG) time, in minutes.
  package let NVGTime: UInt

  /// Number of daytime takeoffs.
  package let dayTakeoffs: UInt

  /// Number of daytime landings.
  package let dayLandings: UInt

  /// Number of nighttime takeoffs.
  package let nightTakeoffs: UInt

  /// Number of nighttime landings.
  package let nightLandings: UInt

  /// Number of full-stop landings (day or night).
  package let fullStopLandings: UInt

  /// Number of nighttime full-stop landings (required for night passenger currency).
  package let nightFullStopLandings: UInt

  /// Number of NVG takeoffs.
  package let takeoffsNVG: UInt

  /// Number of NVG landings.
  package let landingsNVG: UInt

  /// Number of holding patterns flown.
  package let holds: UInt

  /// Flight remarks or comments.
  package let remarks: String?

  /// Whether this flight was a flight review per FAR 61.56.
  package let isFlightReview: Bool

  /// Whether this flight was a practical test (checkride).
  package let isCheckride: Bool

  /// Whether this flight included an instrument proficiency check per FAR 61.57(d).
  package let isIPC: Bool

  /// Whether this flight was a FAR 61.58 proficiency check for type-rated aircraft.
  package let isRecurrent: Bool

  /// Whether this flight included a FAR 61.31(k) NVG proficiency check.
  package let isNVGProficiencyCheck: Bool

  // MARK: Computed Properties

  /// Whether any instrument approaches were flown.
  package var hasApproaches: Bool { !approaches.isEmpty }

  /// The number of instrument approaches flown.
  package var approachCount: Int { approaches.count }

  /// Whether any passengers were aboard.
  package var hasPassengers: Bool { !passengers.isEmpty }

  /// Whether a safety pilot was aboard.
  package var safetyPilotOnboard: Bool { safetyPilot != nil }

  /// Whether any holding patterns were flown.
  package var hasHolds: Bool { holds > 0 }

  /// Whether PIC time was logged.
  package var isPIC: Bool { PICTime > 0 }

  /// Whether dual instruction was received.
  package var isDualReceived: Bool { dualReceivedTime > 0 }

  /// Whether dual instruction was given.
  package var isDualGiven: Bool { dualGivenTime > 0 }

  /// Whether this was a student pilot solo flight.
  package var isStudentSolo: Bool { soloTime > 0 }

  /// Whether any night time was logged.
  package var isNight: Bool { nightTime > 0 }

  /// Whether any actual instrument time was logged.
  package var isIFR: Bool { actualInstrumentTime > 0 }

  /// Total takeoffs (day + night).
  package var totalTakeoffs: UInt { dayTakeoffs + nightTakeoffs }

  /// Total landings (day + night).
  package var totalLandings: UInt { dayLandings + nightLandings }

  /// Whether the aircraft is a tailwheel airplane.
  package var isTailwheel: Bool { aircraft?.tailwheel == true }

  /// PIC time in hours.
  package var PICHours: Double { Double(PICTime) / 60.0 }

  /// Night time in hours.
  package var nightHours: Double { Double(nightTime) / 60.0 }

  /// Actual instrument time in hours.
  package var actualInstrumentHours: Double { Double(actualInstrumentTime) / 60.0 }

  /// Dual given time in hours.
  package var dualGivenHours: Double { Double(dualGivenTime) / 60.0 }

  /// Dual received time in hours.
  package var dualReceivedHours: Double { Double(dualReceivedTime) / 60.0 }

  /// Solo time in hours.
  package var soloHours: Double { Double(soloTime) / 60.0 }

  /// NVG time in hours.
  package var NVGHours: Double { Double(NVGTime) / 60.0 }

  // MARK: Initializers

  init(
    flight: CNFlight,
    aircraft: Aircraft,
    nightFullStopProperty: KeyPath<CNFlight, NSNumber?>,
    proficiencyProperty: KeyPath<CNFlight, String?>,
    checkrideProperty: KeyPath<CNFlight, String?>,
    NVGProficiencyCheckProperty: KeyPath<CNFlight, String?>,
    safetyPilotProperty: KeyPath<CNFlightCrew, CNPerson?>,
    examinerProperty _: KeyPath<CNFlightCrew, CNPerson?>
  ) {
    id = flight.objectID.uriRepresentation()
    self.aircraft = aircraft
    approaches = (flight.flight_flightApproaches?.approaches ?? [])
      .map { .init(approach: $0) }
    PIC = .init(person: flight.flight_flightCrew?.flightCrew_PIC)
    SIC = .init(person: flight.flight_flightCrew?.flightCrew_SIC)
    safetyPilot = .init(person: flight.flight_flightCrew?[keyPath: safetyPilotProperty])
    passengers = (flight.flight_flightPassengers?.passengers ?? [])
      .compactMap { .init(person: $0) }

    date = flight.flight_flightDate

    from = .init(place: flight.flight_fromPlace)
    to = .init(place: flight.flight_toPlace)

    PICTime = flight.flight_pic?.uintValue ?? 0
    soloTime = flight.flight_solo?.uintValue ?? 0
    nightTime = flight.flight_night?.uintValue ?? 0
    dualGivenTime = flight.flight_dualGiven?.uintValue ?? 0
    dualReceivedTime = flight.flight_dualReceived?.uintValue ?? 0
    actualInstrumentTime = flight.flight_actualInstrument?.uintValue ?? 0
    NVGTime = flight.flight_nightVisionGoggle?.uintValue ?? 0

    dayTakeoffs = flight.flight_dayTakeoffs?.uintValue ?? 0
    nightTakeoffs = flight.flight_nightTakeoffs?.uintValue ?? 0
    dayLandings = flight.flight_dayLandings?.uintValue ?? 0
    nightLandings = flight.flight_nightLandings?.uintValue ?? 0
    fullStopLandings = flight.flight_fullStops?.uintValue ?? 0
    nightFullStopLandings = flight[keyPath: nightFullStopProperty]?.uintValue ?? 0
    takeoffsNVG = flight.flight_nightVisionGoggleTakeoffs?.uintValue ?? 0
    landingsNVG = flight.flight_nightVisionGoggleLandings?.uintValue ?? 0

    holds = flight.flight_holds?.uintValue ?? 0

    isFlightReview = flight.flight_review?.boolValue ?? false
    isIPC = flight.flight_instrumentProficiencyCheck?.boolValue ?? false
    isRecurrent = flight[keyPath: proficiencyProperty]?.isPresent ?? false
    isCheckride = flight[keyPath: checkrideProperty]?.isPresent ?? false
    isNVGProficiencyCheck = flight[keyPath: NVGProficiencyCheckProperty]?.isPresent ?? false

    remarks = flight.flight_remarks
  }
}
