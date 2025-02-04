
import Foundation

public class TJLabsResourceManager {
    public static let shared = TJLabsResourceManager()
    
    let pathPixelManager = TJLabsPathPixelManager()

    public init() { }
    
    // MARK: - Public Methods
    public func loadMapResource(region: ResourceRegion, sectorId: Int) {
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadImage(region: region, sectorId: sectorId)
        self.loadScaleOffset(region: region, sectorId: sectorId)
        self.loadUnit(region: region, sectorId: sectorId)
    }
    
    public func loadJupiterResource(region: ResourceRegion, sectorId: Int) {
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadRouteTrack(region: region, sectorId: sectorId)
    }
    
    // MARK: - Public Get Methods
    public func getPathPixelData() -> [String: PathPixelData] {
        return TJLabsPathPixelManager.ppDataMap
    }
    
    public func getPathPixelDataIsLoaded() -> [String: PathPixelDataIsLoaded] {
        return TJLabsPathPixelManager.ppDataLoaded
    }
    
    // MARK: - Public Update Methods
    public func updatePathPixelData(key: String, URL: String) {
        TJLabsPathPixelManager.isPerformed = true
        self.pathPixelManager.updatePathPixel(key: key, pathPixelUrlFromServer: URL)
    }
    
    // MARK: - Private Methods
    private func loadPathPixel(region: ResourceRegion, sectorId: Int) {
        if !TJLabsPathPixelManager.isPerformed {
            TJLabsPathPixelManager.isPerformed = true
            pathPixelManager.loadPathPixel(sectorId: sectorId, completion: { isSuccess, msg in
                print("(TJLabsResource) loadResources (NAVIGATION) : \(isSuccess) , \(msg)")
            })
        } else {
            print("(TJLabsResource) Info : loadPathPixel already performed")
        }
    }
    
    private func loadImage(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func loadScaleOffset(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func loadUnit(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func loadRouteTrack(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func setRegion(region: ResourceRegion) {
        TJLabsResourceNetworkConstants.setServerURL(region: region)
        TJLabsFileDownloader.shared.setRegion(region: region)
        pathPixelManager.setRegion(region: region)
    }
}
