
import Foundation

public class TJLabsResourceNetworkConstants {
    static let TIMEOUT_VALUE_PUT: TimeInterval = 5.0
    
    static let USER_PATHPIXEL_SERVER_VERSION = "2024-11-14"
    
    private static let HTTP_PREFIX = "https://"
    private static let JUPITER_SUFFIX = ".jupiter.tjlabs.dev"
    
    private(set) static var REGION_PREFIX = "ap-northeast-2."
    private(set) static var REGION_NAME = "Korea"
    
    private(set) static var USER_URL = HTTP_PREFIX + REGION_PREFIX + "user" + JUPITER_SUFFIX
    private(set) static var IMAGE_URL = HTTP_PREFIX + REGION_PREFIX + "img" + JUPITER_SUFFIX
    private(set) static var CSV_URL = HTTP_PREFIX + REGION_PREFIX + "csv" + JUPITER_SUFFIX
    private(set) static var CLIENT_URL = HTTP_PREFIX + REGION_PREFIX + "client" + JUPITER_SUFFIX
    
    public static func setServerURL(region: ResourceRegion) {
        switch region {
        case .KOREA:
            REGION_PREFIX = "ap-northeast-2."
        case .CANADA:
            REGION_PREFIX = "ca-central-1."
        case .US_EAST:
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
    
    public static func getUserPathPixelVersion() -> String {
        return USER_PATHPIXEL_SERVER_VERSION
    }
    
    public static func getUserPathPixelURL() -> String {
        return USER_URL + "/" + USER_PATHPIXEL_SERVER_VERSION + "/path"
    }

}
