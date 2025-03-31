package struct Approach: Record {

    // MARK: Properties

    package let place: Place?
    package let type: ApproachType?
    package let runway: String?
    package let count: UInt?

    // MARK: Initializers

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

    package enum ApproachType: String, RecordEnum {
        case GCA
        case GLS
        case GPS_GNSS = "GPS/GNSS"
        case IGS
        case ILS
        case JPALS
        case GBAS
        case LNAV
        case LNAV_VNAV = "LNAV/VNAV"
        case LPV
        case MLS
        case PAR
        case WAAS
        case ARA
        case contact = "CONTACT"
        case DME
        case GPS
        case IAN
        case LDA
        case LOC
        case LOC_BC = "LOC BC"
        case LOC_DME = "LOC/DME"
        case LP
        case NDB
        case RNAV
        case RNP
        case SDF
        case SRA
        case TACAN
        case visual = "VISUAL"
        case VOR
        case VOR_DME = "VOR/DME"
    }
}
