
import Foundation

public enum ResourceRegion {
    case KOREA, US, CANADA
}

public enum TJLabsService: String {
    case NAVIGATION = "jupiter"
    case MAP = "map"
    case CHAT = "chat"
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

struct InputSector: Codable {
    var sector_id: Int = 0
    var operating_system: String = "iOS"
    
    init(sector_id: Int, operating_system: String) {
        self.sector_id = sector_id
        self.operating_system = operating_system
    }
}

struct PathPixel: Codable {
    let building_name: String
    let level_name: String
    let url: String
}

struct OutputPathPixel: Codable {
    let path_pixel_list: [PathPixel]
}
