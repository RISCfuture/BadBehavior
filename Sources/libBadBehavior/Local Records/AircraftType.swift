package struct AircraftType: IdentifiableRecord {
    
    // MARK: Properties
    
    package let id: String
    package let type: String
    package let category: Category
    package let `class`: Class?
    package let engineType: EngineType?
    
    package let simType: SimulatorType?
    package let simAircraftCategoryClass: SimulatorCategoryClass?
    
    // MARK: Computed Properties
    
    package var simCategory: AircraftType.Category? {
        switch simAircraftCategoryClass {
            case .airplaneSingleEngineLand, .airplaneSingleEngineSea, .airplaneMultiEngineLand, .airplaneMultiEngineSea:
                return .airplane
            case .glider: return .glider
            case nil: return nil
        }
    }
    package var simClass: AircraftType.Class? {
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
    
    init(aircraftType: CNAircraftType,
         typeCodeProperty: KeyPath<CNAircraftType, String?>,
         simTypeProperty: KeyPath<CNAircraftType, String?>,
         simCategoryProperty: KeyPath<CNAircraftType, String?>) {
        
        id = aircraftType.aircraftType_type
        type = aircraftType[keyPath: typeCodeProperty] ?? aircraftType.aircraftType_type
        category = .init(rawValue: aircraftType.aircraftType_category.logTenProperty_key)!
        `class` = {
            guard let title = aircraftType.aircraftType_aircraftClass?.logTenProperty_key else { return nil }
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
    
    package enum Category: String, RecordEnum {
        case airplane = "flight_category1"
        case rotorcraft = "flight_category2"
        case poweredLift = "flight_category3"
        case glider = "flight_category4"
        case lighterThanAir = "flight_category5"
        case simulator = "flight_category6"
        case trainingDevice = "flight_category7"
        case PC_ATD = "flight_category8"
        case poweredParachute = "flight_category9"
        case weightShiftControl = "flight_category10"
        case UAV = "flight_category11"
        case other = "flight_category12"
    }
    
    package enum Class: String, RecordEnum {
        case multiEngineLand = "flight_aircraftClass1"
        case singleEngineLand = "flight_aircraftClass2"
        case multiEngineSea = "flight_aircraftClass3"
        case singleEngineSea = "flight_aircraftClass4"
        case other = "flight_aircraftClass5"
        case gyroplane = "flight_aircraftClass6"
        case airship = "flight_aircraftClass7"
        case freeBalloon = "flight_aircraftClass8"
        case helicopter = "flight_aircraftClass9"
    }
    
    package enum EngineType: String, RecordEnum {
        case jet = "flight_engineType1"
        case turbine = "flight_engineType2"
        case turboprop = "flight_engineType3"
        case reciprocating = "flight_engineType4"
        case nonpowered = "flight_engineType5"
        case turboshaft = "flight_engineType6"
        case turbofan = "flight_engineType7"
        case ramjet = "flight_engineType8"
        case twoCycle = "flight_engineType9"
        case fourCycle = "flight_engineType10"
        case other = "flight_engineType11"
        case electric = "flight_engineType12"
    }
    
    package enum SimulatorType: String, RecordEnum {
        case BATD
        case AATD
        case FTD
        case FFS
    }
    
    package enum SimulatorCategoryClass: String, RecordEnum {
        case airplaneSingleEngineLand = "ASEL"
        case airplaneSingleEngineSea = "ASES"
        case airplaneMultiEngineLand = "AMEL"
        case airplaneMultiEngineSea = "AMES"
        case glider = "GL"
    }
}
