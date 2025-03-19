
import Foundation

public class TJLabsResourceNetworkConstants {
    static let TIMEOUT_VALUE_PUT: TimeInterval = 5.0
    
    // MARK: - VERSION
    static let USER_LEVEL_SERVER_VERSION = "2024-11-13"
    static let USER_PATHPIXEL_SERVER_VERSION = "2024-11-14"
    static let USER_SCALE_SERVER_VERSION = "2024-11-14"
    static let USER_PARAM_SERVER_VERSION = "2024-11-13"
    static let USER_GEO_SERVER_VERSION = "2024-11-15"
    static let USER_ENTERANCE_SERVER_VERSION = "2024-11-14"
    static let USER_UNIT_SERVER_VERSIOM = "2024-11-13"
    
    // MARK: - PREFIX & SUFFIX
    private static let HTTP_PREFIX = "https://"
    private static let JUPITER_SUFFIX = ".jupiter.tjlabs.dev"
    private(set) static var REGION_PREFIX = "ap-northeast-2."
    
    // MARK: - SERVER URL
    private(set) static var USER_URL = HTTP_PREFIX + REGION_PREFIX + "user" + JUPITER_SUFFIX
    private(set) static var IMAGE_URL = HTTP_PREFIX + REGION_PREFIX + "img" + JUPITER_SUFFIX
    private(set) static var CSV_URL = HTTP_PREFIX + REGION_PREFIX + "csv" + JUPITER_SUFFIX
    private(set) static var CLIENT_URL = HTTP_PREFIX + REGION_PREFIX + "client" + JUPITER_SUFFIX
    
    public static func setServerURL(region: String) {
        switch region {
        case ResourceRegion.KOREA.rawValue:
            REGION_PREFIX = "ap-northeast-2."
        case ResourceRegion.CANADA.rawValue:
            REGION_PREFIX = "ca-central-1."
        case ResourceRegion.US_EAST.rawValue:
            REGION_PREFIX = "us-east-1."
        default:
            REGION_PREFIX = ""
        }
        
        USER_URL = HTTP_PREFIX + REGION_PREFIX + "user" + JUPITER_SUFFIX
        IMAGE_URL = HTTP_PREFIX + REGION_PREFIX + "img" + JUPITER_SUFFIX
        CSV_URL = HTTP_PREFIX + REGION_PREFIX + "csv" + JUPITER_SUFFIX
        CLIENT_URL = HTTP_PREFIX + REGION_PREFIX + "client" + JUPITER_SUFFIX
    }
    
    public static func getUserBaseURL() -> String {
        return USER_URL
    }
    
    public static func getImageBaseURL() -> String {
        return IMAGE_URL
    }
    
    // MARK: - Level
    public static func getUserLevelVersion() -> String {
        return USER_LEVEL_SERVER_VERSION
    }
    
    public static func getUserLevelURL() -> String {
        return USER_URL + "/" + USER_LEVEL_SERVER_VERSION + "/level"
    }
    
    // MARK: - Path-Pixel
    public static func getUserPathPixelVersion() -> String {
        return USER_PATHPIXEL_SERVER_VERSION
    }
    
    public static func getUserPathPixelURL() -> String {
        return USER_URL + "/" + USER_PATHPIXEL_SERVER_VERSION + "/path"
    }
    
    
    // MARK: - Scale
    public static func getUserScaleVersion() -> String {
        return USER_SCALE_SERVER_VERSION
    }
    
    public static func getUserScaleURL() -> String {
        return USER_URL + "/" + USER_SCALE_SERVER_VERSION + "/scale"
    }
    
    // MARK: - Param
    public static func getUserParamVersion() -> String {
        return USER_PARAM_SERVER_VERSION
    }
    
    public static func getUserParamURL() -> String {
        return USER_URL + "/" + USER_PARAM_SERVER_VERSION + "/parameter"
    }
    
    // MARK: - Geo
    public static func getUserGeoVersion() -> String {
        return USER_GEO_SERVER_VERSION
    }
    
    public static func getUserGeoURL() -> String {
        return USER_URL + "/" + USER_GEO_SERVER_VERSION + "/geofence"
    }
    
    // MARK: - Entrance
    public static func getUserEntranceVersion() -> String {
        return USER_ENTERANCE_SERVER_VERSION
    }
    
    public static func getUserEntranceURL() -> String {
        return USER_URL + "/" + USER_ENTERANCE_SERVER_VERSION + "/entrance"
    }
    
    // MARK: - Unit
    public static func getUserUnitVersion() -> String {
        return USER_UNIT_SERVER_VERSIOM
    }
    
    public static func getUserUnitURL() -> String {
        return USER_URL + "/" + USER_UNIT_SERVER_VERSIOM + "/unit"
    }
}
