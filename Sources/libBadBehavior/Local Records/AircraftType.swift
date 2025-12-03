/// The type specification for an aircraft.
///
/// `AircraftType` describes the category, class, and engine type of an aircraft. For simulators
/// and flight training devices, it also includes the simulated aircraft's category and class.
///
/// ## FAA Classification
///
/// Aircraft are classified by:
/// - **Category**: The broad classification (airplane, rotorcraft, glider, etc.)
/// - **Class**: The subclassification within a category (single-engine land, multi-engine sea, etc.)
/// - **Engine Type**: The type of powerplant (reciprocating, turboprop, jet, etc.)
///
/// ## Simulators and Training Devices
///
/// For simulators (FFS) and flight training devices (FTD, AATD, BATD), the ``simType`` property
/// indicates the device type, and ``simAircraftCategoryClass`` indicates what category and class
/// of aircraft the device simulates. This is important for determining currency credit.
package struct AircraftType: IdentifiableRecord {

  // MARK: Properties

  /// The unique identifier for this aircraft type (typically from LogTen's internal ID).
  package let id: String

  /// The aircraft type designator (e.g., "C172", "PA28", "B738").
  package let type: String

  /// The FAA aircraft category.
  package let category: Category

  /// The FAA aircraft class within the category.
  package let `class`: Class?

  /// The type of engine installed.
  package let engineType: EngineType?

  /// The type of simulator or training device, if applicable.
  ///
  /// - `BATD`: Basic Aviation Training Device
  /// - `AATD`: Advanced Aviation Training Device
  /// - `FTD`: Flight Training Device
  /// - `FFS`: Full Flight Simulator
  package let simType: SimulatorType?

  /// The category and class that a simulator or FTD represents.
  package let simAircraftCategoryClass: SimulatorCategoryClass?

  // MARK: Computed Properties

  /// The aircraft category that this simulator represents.
  ///
  /// Returns `nil` for actual aircraft or if not specified for simulators.
  package var simCategory: Self.Category? {
    switch simAircraftCategoryClass {
      case .airplaneSingleEngineLand, .airplaneSingleEngineSea, .airplaneMultiEngineLand,
        .airplaneMultiEngineSea:
        return .airplane
      case .glider: return .glider
      case nil: return nil
    }
  }

  /// The aircraft class that this simulator represents.
  ///
  /// Returns `nil` for actual aircraft, glider simulators, or if not specified.
  package var simClass: Self.Class? {
    switch simAircraftCategoryClass {
      case .airplaneSingleEngineLand: return .singleEngineLand
      case .airplaneSingleEngineSea: return .singleEngineSea
      case .airplaneMultiEngineLand: return .multiEngineLand
      case .airplaneMultiEngineSea: return .multiEngineSea
      case .glider: return nil
      case nil: return nil
    }
  }

  // MARK: Initializers

  init(
    aircraftType: CNAircraftType,
    typeCodeProperty: KeyPath<CNAircraftType, String?>,
    simTypeProperty: KeyPath<CNAircraftType, String?>,
    simCategoryProperty: KeyPath<CNAircraftType, String?>
  ) {

    id = aircraftType.aircraftType_type
    type = aircraftType[keyPath: typeCodeProperty] ?? aircraftType.aircraftType_type
    category = .init(rawValue: aircraftType.aircraftType_category.logTenProperty_key)!
    `class` = {
      guard let title = aircraftType.aircraftType_aircraftClass?.logTenProperty_key else {
        return nil
      }
      return .init(rawValue: title)
    }()

    simType = {
      guard let typeString = aircraftType[keyPath: simTypeProperty] else { return nil }
      return .init(rawValue: typeString)
    }()
    simAircraftCategoryClass = {
      guard let typeString = aircraftType[keyPath: simCategoryProperty] else { return nil }
      return .init(rawValue: typeString)
    }()
    engineType = {
      guard let key = aircraftType.aircraftType_engineType?.logTenProperty_key else { return nil }
      return .init(rawValue: key)
    }()
  }

  // MARK: Enums

  /// FAA aircraft categories as defined in 14 CFR 1.1.
  ///
  /// Categories represent the broad classification of aircraft based on their intended use
  /// and operating characteristics.
  package enum Category: String, RecordEnum {
    /// Airplane: An engine-driven, fixed-wing aircraft heavier than air.
    case airplane = "flight_category1"
    /// Rotorcraft: A heavier-than-air aircraft that depends on rotating wings for lift.
    case rotorcraft = "flight_category2"
    /// Powered-lift: A heavier-than-air aircraft capable of vertical takeoff/landing.
    case poweredLift = "flight_category3"
    /// Glider: A heavier-than-air aircraft that does not depend on an engine.
    case glider = "flight_category4"
    /// Lighter-than-air: An aircraft that can rise and remain suspended by using contained gas.
    case lighterThanAir = "flight_category5"
    /// Full flight simulator (FFS).
    case simulator = "flight_category6"
    /// Flight training device (FTD).
    case trainingDevice = "flight_category7"
    /// Personal computer-based aviation training device.
    case PC_ATD = "flight_category8"
    /// Powered parachute: A powered aircraft with a parafoil wing.
    case poweredParachute = "flight_category9"
    /// Weight-shift-control aircraft (trikes).
    case weightShiftControl = "flight_category10"
    /// Unmanned aerial vehicle.
    case UAV = "flight_category11"
    /// Other or unspecified category.
    case other = "flight_category12"

    /// A localized, human-readable description of the category.
    package var localizedDescription: String {
      switch self {
        case .airplane: return String(localized: "Airplane")
        case .rotorcraft: return String(localized: "Rotorcraft")
        case .poweredLift: return String(localized: "Powered Lift")
        case .glider: return String(localized: "Glider")
        case .lighterThanAir: return String(localized: "Lighter-Than-Air")
        case .simulator: return String(localized: "Simulator")
        case .trainingDevice: return String(localized: "Training Device")
        case .PC_ATD: return String(localized: "PC-ATD")
        case .poweredParachute: return String(localized: "Powered Parachute")
        case .weightShiftControl: return String(localized: "Weight-Shift-Control")
        case .UAV: return String(localized: "UAV")
        case .other: return String(localized: "Other")
      }
    }
  }

  /// FAA aircraft classes as defined in 14 CFR 1.1.
  ///
  /// Classes are subdivisions within aircraft categories based on operating characteristics.
  package enum Class: String, RecordEnum {
    /// Multi-engine land airplane.
    case multiEngineLand = "flight_aircraftClass1"
    /// Single-engine land airplane.
    case singleEngineLand = "flight_aircraftClass2"
    /// Multi-engine sea (seaplane).
    case multiEngineSea = "flight_aircraftClass3"
    /// Single-engine sea (seaplane).
    case singleEngineSea = "flight_aircraftClass4"
    /// Other or unspecified class.
    case other = "flight_aircraftClass5"
    /// Gyroplane (a rotorcraft with unpowered rotor in autorotation).
    case gyroplane = "flight_aircraftClass6"
    /// Airship (a powered lighter-than-air aircraft).
    case airship = "flight_aircraftClass7"
    /// Free balloon (an unpowered lighter-than-air aircraft).
    case freeBalloon = "flight_aircraftClass8"
    /// Helicopter (a rotorcraft with powered rotor).
    case helicopter = "flight_aircraftClass9"

    /// A localized, human-readable description of the class.
    package var localizedDescription: String {
      switch self {
        case .multiEngineLand: return String(localized: "Multi-Engine Land")
        case .singleEngineLand: return String(localized: "Single-Engine Land")
        case .multiEngineSea: return String(localized: "Multi-Engine Sea")
        case .singleEngineSea: return String(localized: "Single-Engine Sea")
        case .other: return String(localized: "Other")
        case .gyroplane: return String(localized: "Gyroplane")
        case .airship: return String(localized: "Airship")
        case .freeBalloon: return String(localized: "Free Balloon")
        case .helicopter: return String(localized: "Helicopter")
      }
    }
  }

  /// Aircraft engine types.
  ///
  /// Engine type affects type rating requirements (turbine-powered aircraft generally
  /// require type ratings).
  package enum EngineType: String, RecordEnum {
    /// Turbojet engine (jet).
    case jet = "flight_engineType1"
    /// Turbine engine (generic).
    case turbine = "flight_engineType2"
    /// Turboprop engine.
    case turboprop = "flight_engineType3"
    /// Reciprocating (piston) engine.
    case reciprocating = "flight_engineType4"
    /// Non-powered (gliders).
    case nonpowered = "flight_engineType5"
    /// Turboshaft engine (helicopters).
    case turboshaft = "flight_engineType6"
    /// Turbofan engine.
    case turbofan = "flight_engineType7"
    /// Ramjet engine.
    case ramjet = "flight_engineType8"
    /// Two-cycle piston engine.
    case twoCycle = "flight_engineType9"
    /// Four-cycle piston engine.
    case fourCycle = "flight_engineType10"
    /// Other or unspecified engine type.
    case other = "flight_engineType11"
    /// Electric motor.
    case electric = "flight_engineType12"
  }

  /// Types of flight simulation devices as defined by the FAA.
  ///
  /// Different simulator types provide different levels of currency credit.
  package enum SimulatorType: String, RecordEnum {
    /// Basic Aviation Training Device.
    case BATD
    /// Advanced Aviation Training Device.
    case AATD
    /// Flight Training Device (FAA qualified).
    case FTD
    /// Full Flight Simulator (highest fidelity).
    case FFS
  }

  /// Combined category and class for simulators, using standard abbreviations.
  ///
  /// This indicates what type of aircraft a simulator represents for currency purposes.
  package enum SimulatorCategoryClass: String, RecordEnum {
    /// Airplane Single-Engine Land.
    case airplaneSingleEngineLand = "ASEL"
    /// Airplane Single-Engine Sea.
    case airplaneSingleEngineSea = "ASES"
    /// Airplane Multi-Engine Land.
    case airplaneMultiEngineLand = "AMEL"
    /// Airplane Multi-Engine Sea.
    case airplaneMultiEngineSea = "AMES"
    /// Glider.
    case glider = "GL"
  }
}
