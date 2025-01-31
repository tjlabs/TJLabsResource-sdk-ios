
import Foundation

public class TJLabsResourceManager {
    public static let shared = TJLabsResourceManager()
    
    let pathPixelManager = TJLabsPathPixelManager()

    public init() { }
    
    // MARK: - Public Methods
    public func loadResources(region: ResourceRegion, sectorId: Int, completion: @escaping (Bool, String) -> Void) {
        self.setRegion(region: region)
        let sectorServices = getSectorServiceFromServer(region: region, sectorId: sectorId)
        var loadedServices = [String]()
        for service in sectorServices {
            loadedServices.append(service)
            switch (service) {
            case TJLabsService.NAVIGATION.rawValue:
                pathPixelManager.loadPathPixel(sectorId: sectorId, completion: { isSuccess, msg in
                    completion(isSuccess, msg)
                })
            case TJLabsService.MAP.rawValue:
                if !loadedServices.contains(TJLabsService.NAVIGATION.rawValue) {
                    pathPixelManager.loadPathPixel(sectorId: sectorId, completion: { isSuccess, msg in
                        completion(isSuccess, msg)
                    })
                } else {
                    completion(true, "")
                }
            case TJLabsService.CHAT.rawValue:
                print("wow")
            default:
                print("wow")
            }
        }
        
//        completion(true, "")
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
        
        services = [TJLabsService.NAVIGATION.rawValue, TJLabsService.MAP.rawValue]
        
        return services
    }
    
    private func setRegion(region: ResourceRegion) {
        TJLabsResourceNetworkConstants.setServerURL(region: region)
        TJLabsFileDownloader.shared.setRegion(region: region)
        pathPixelManager.setRegion(region: region)
    }
}
