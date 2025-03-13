
import Foundation
import UIKit

public enum ResourceRegion: String {
    case KOREA = "KOREA"
    case CANADA = "CANADA"
    case US_EAST = "US_EAST"
}

public struct PathPixelData {
    public var roadType: [Int] = []
    public var nodeNumber: [Int] = []
    public var road: [[Double]] = [[]]
    public var roadMinMax: [Double] = []
    public var roadScale: [Double] = []
    public var roadHeading: [String] = []
    
    public init(roadType: [Int], nodeNumber: [Int], road: [[Double]], roadMinMax:[Double], roadScale: [Double], roadHeading: [String]) {
        self.roadType = roadType
        self.nodeNumber = nodeNumber
        self.road = road
        self.roadMinMax = roadMinMax
        self.roadScale = roadScale
        self.roadHeading = roadHeading
    }
}

public struct PathPixelDataIsLoaded {
    public var isLoaded: Bool = false
    public var URL: String = ""
    
    public init(isLoaded: Bool, URL: String) {
        self.isLoaded = isLoaded
        self.URL = URL
    }
}

public struct EntranceData {
    public var number: Int = 0
    public var networkStatus: Bool = false
    public var velocityScale: Double = 0
    public var innerWardId: String = ""
    public var innerWardRssi: Double = 0
    public var innerWardCoord: [Double] = []
    
    init(number: Int, networkStatus: Bool, velocityScale: Double, innerWardId: String, innerWardRssi: Double, innerWardCoord: [Double]) {
        self.number = number
        self.networkStatus = networkStatus
        self.velocityScale = velocityScale
        self.innerWardId = innerWardId
        self.innerWardRssi = innerWardRssi
        self.innerWardCoord = innerWardCoord
    }
}

public struct EntranceRouteData {
    public var routeLevel: [String] = []
    public var route: [[Double]] = [[]]
    
    public init(routeLevel: [String], route: [[Double]]) {
        self.routeLevel = routeLevel
        self.route = route
    }
}

public struct EntranceRouteDataIsLoaded {
    public var isLoaded: Bool = false
    public var URL: String = ""
    
    public init(isLoaded: Bool, URL: String) {
        self.isLoaded = isLoaded
        self.URL = URL
    }
}

public struct UnitData: Codable {
    public let category: Int
    public let number: Int
    public let name: String
    public let accessibility: String
    public let restriction: Bool
    public let visibility: Bool
    public let x: Double
    public let y: Double
}

public struct ParameterData: Codable {
    public let trajectory_length: Double
    public let trajectory_diagonal: Double
    public let debug: Bool
    public let standard_rss: [Int]
}

// MARK: - POST Input
struct SectorIdInput: Codable {
    var sector_id: Int = 0
    
    init(sector_id: Int) {
        self.sector_id = sector_id
    }
}

struct SectorIdOsInput: Codable {
    var sector_id: Int = 0
    var operating_system: String = "iOS"
    
    init(sector_id: Int, operating_system: String) {
        self.sector_id = sector_id
        self.operating_system = operating_system
    }
}

// MARK: - POST Output
// MARK: - PathPixel
struct PathPixelOutput: Codable {
    let building_name: String
    let level_name: String
    let url: String
}

struct PathPixelOutputList: Codable {
    let path_pixel_list: [PathPixelOutput]
}

// MARK: - Entrance
struct EntranceRF: Codable {
    let id: String
    let rss: Double
    let pos: [Double]
    let direction: Double
}

struct Entrance: Codable {
    let spot_number: Int
    let outermost_ward_id: String
    let scale: Double
    let url: String
    let network_status: Bool
    let innermost_ward: EntranceRF
}

struct EntranceList: Codable {
    let building_name: String
    let level_name: String
    let entrances: [Entrance]
}

struct EntranceOutputList: Codable {
    let entrance_list: [EntranceList]
}

// MARK: - Building Level
struct LevelOuput: Codable {
    let building_name: String
    let level_name: String
}

struct LevelOutputList: Codable {
    let level_list: [LevelOuput]
}

// MARK: - Scale Offset
struct ScaleOutputList: Codable {
    let scale_list: [ScaleOutput]
}

struct ScaleOutput: Codable {
    let building_name: String
    let level_name: String
    let image_scale: [Double]
}

// MARK: - Unit
struct UnitOutput: Codable {
    let building_name: String
    let level_name: String
    let units: [UnitData]
}

struct UnitOutputList: Codable {
    let unit_list: [UnitOutput]
}

// MARK: - Parameter
struct ParameterOutput: Codable {
    let trajectory_length: Double
    let trajectory_diagonal: Double
    let debug: Bool
    let standard_rss: [Int]
}


// MARK: - Protocol
public enum ResourceError {
    case PathPixel
    case BuildingLevel
    case Image
    case Scale
    case Entrance
    case Unit
    case Param
}


public protocol TJLabsResourceManagerDelegate: AnyObject {
    func onBuildingLevelData(_ manager: TJLabsResourceManager, isOn: Bool, buildingLevelData: [String: [String]])
    func onPathPixelData(_ manager: TJLabsResourceManager, isOn: Bool, pathPixelKey: String, data: PathPixelData?)
    func onBuildingLevelImageData(_ manager: TJLabsResourceManager, isOn: Bool, imageKey: String, data: UIImage?)
    func onScaleOffsetData(_ manager: TJLabsResourceManager, isOn: Bool, scaleKey: String, data: [Double]?)
    func onUnitData(_ manager: TJLabsResourceManager, isOn: Bool, unitKey: String, data: [UnitData]?)
    func onEntranceData(_ manager: TJLabsResourceManager, isOn: Bool, entranceKey: String, data: EntranceRouteData?)
    func onParamData(_ manager: TJLabsResourceManager, isOn: Bool, data: ParameterData?)
    func onError(_ manager: TJLabsResourceManager, error: ResourceError)
}
