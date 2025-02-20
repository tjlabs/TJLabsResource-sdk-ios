
import Foundation

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

// MARK: - Protocol
public protocol TJLabsResourceManagerDelegate: AnyObject {
    
}
