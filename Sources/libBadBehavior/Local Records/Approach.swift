/// An instrument approach procedure record from a flight.
///
/// `Approach` represents an instrument approach flown during a flight. Approaches are
/// counted toward IFR currency requirements per FAR 61.57(c).
package struct Approach: Record {

  // MARK: Properties

  /// The airport where the approach was conducted.
  package let place: Place?

  /// The type of instrument approach procedure.
  package let type: ApproachType?

  /// The runway used for the approach (stored in the comment field).
  package let runway: String?

  /// The number of times this approach was flown.
  package let count: UInt?

  // MARK: Initializers

  /// Creates an Approach from a Core Data CNApproach object.
  ///
  /// - Parameter approach: The Core Data approach object.
  init(approach: CNApproach) {
    place = .init(place: approach.approach_place)
    type = {
      guard let type = approach.approach_type else { return nil }
      return .init(rawValue: type)
    }()
    runway = approach.approach_comment
    count = approach.approach_quantity?.uintValue
  }

  // MARK: Enums

  /// Types of instrument approach procedures.
  ///
  /// This enumeration covers precision approaches (ILS, GLS, PAR), non-precision approaches
  /// (VOR, NDB, LOC), and RNAV/GPS approaches (LNAV, LPV, RNP).
  package enum ApproachType: String, RecordEnum {
    /// Ground Controlled Approach (radar).
    case GCA
    /// GBAS Landing System.
    case GLS
    /// GPS/GNSS approach.
    case GPS_GNSS = "GPS/GNSS"
    /// Instrument Guidance System.
    case IGS
    /// Instrument Landing System.
    case ILS
    /// Joint Precision Approach and Landing System.
    case JPALS
    /// Ground-Based Augmentation System.
    case GBAS
    /// Lateral Navigation (non-precision GPS).
    case LNAV
    /// LNAV with Vertical Navigation.
    case LNAV_VNAV = "LNAV/VNAV"
    /// Localizer Performance with Vertical guidance.
    case LPV
    /// Microwave Landing System.
    case MLS
    /// Precision Approach Radar.
    case PAR
    /// Wide Area Augmentation System.
    case WAAS
    /// Airborne Radar Approach.
    case ARA
    /// Contact approach.
    case contact = "CONTACT"
    /// DME arc approach.
    case DME
    /// GPS approach (non-WAAS).
    case GPS
    /// Integrated Approach Navigation.
    case IAN
    /// Localizer-type Directional Aid.
    case LDA
    /// Localizer approach.
    case LOC
    /// Localizer Back Course.
    case LOC_BC = "LOC BC"
    /// Localizer with DME.
    case LOC_DME = "LOC/DME"
    /// Localizer Performance (without vertical guidance).
    case LP
    /// Non-Directional Beacon approach.
    case NDB
    /// Area Navigation approach.
    case RNAV
    /// Required Navigation Performance approach.
    case RNP
    /// Simplified Directional Facility.
    case SDF
    /// Surveillance Radar Approach.
    case SRA
    /// Tactical Air Navigation approach.
    case TACAN
    /// Visual approach.
    case visual = "VISUAL"
    /// VOR approach.
    case VOR
    /// VOR with DME.
    case VOR_DME = "VOR/DME"
  }
}
