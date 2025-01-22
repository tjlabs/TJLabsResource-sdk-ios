
import Foundation

public class TJLabsResourceManager {
    public static let shared = TJLabsResourceManager()
    
    let pathPixelManager = TJLabsPathPixelManager()

    init() { }
    
    // MARK: - Public Methods
    public func updateResources(region: ResourceRegion, sectorId: Int, completion: @escaping (Bool, String) -> Void) {
        TJLabsResourceNetworkConstants.setServerURL(region: region)
        let sectorServices = getSectorServiceFromServer(region: region, sectorId: sectorId)
        for service in sectorServices {
            switch (service) {
            case TJLabsService.NAVIGATION.rawValue:
                pathPixelManager.loadPathPixel(sectorId: sectorId, completion: { isSuccess, msg in
                    completion(isSuccess, msg)
                })
            case TJLabsService.MAP.rawValue:
                print("wow")
            case TJLabsService.CHAT.rawValue:
                print("wow")
            default:
                print("wow")
            }
        }
        
        completion(true, "")
    }
    
    public func getPathPixelData() -> [String: PathPixelData] {
        return TJLabsPathPixelManager.ppDataMap
    }
    
    public func getPathPixelDataIsLoaded() -> [String: PathPixelDataIsLoaded] {
        return TJLabsPathPixelManager.ppDataLoaded
    }
    
    public func updatePathPixelData(key: String, URL: String) {
        self.pathPixelManager.updatePathPixel(key: key, pathPixelUrlFromServer: URL)
    }
    
    // MARK: - Private Methods
    private func getSectorServiceFromServer(region: ResourceRegion, sectorId: Int) -> [String] {
        var services = [String]()
        
        services = [TJLabsService.NAVIGATION.rawValue]
        
        return services
    }
}
