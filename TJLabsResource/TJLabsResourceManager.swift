
import Foundation

public class TJLabsResourceManager: ScaleOffsetDelegate {
    func onScaleOffsetData(_ manager: TJLabsScaleOffsetManager, isOn: Bool) {
        if isOn {
            
        } else {
            // Error
            TJLabsScaleOffsetManager.isPerformed = false
        }
    }
    
    public static let shared = TJLabsResourceManager()
    public weak var delegate: TJLabsResourceManagerDelegate?
    
    let buildingLevelManager = TJLabsBuildingLevelManager()
    let pathPixelManager = TJLabsPathPixelManager()
    let imageManager = TJLabsImageManager()
    let scaleOffsetManager = TJLabsScaleOffsetManager()

    public init() {
        scaleOffsetManager.delegate = self
    }
    
    // MARK: - Public Methods
    public func loadMapResource(region: ResourceRegion, sectorId: Int) {
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadScaleOffset(region: region, sectorId: sectorId)
        self.loadUnit(region: region, sectorId: sectorId)
        loadBuildingLevel(region: region, sectorId: sectorId, completion: { [self] isSuccess, buildingLevelData in
            if isSuccess {
                self.loadImage(region: region, sectorId: sectorId)
            }
        })
    }
    
    public func loadJupiterResource(region: ResourceRegion, sectorId: Int) {
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadRouteTrack(region: region, sectorId: sectorId)
    }
    
    // MARK: - Public Get Methods
    public func getBuildingLevelData() -> [Int: [String: [String]]] {
        return TJLabsBuildingLevelManager.buildingLevelDataMap
    }
    
    public func getPathPixelData() -> [String: PathPixelData] {
        return TJLabsPathPixelManager.ppDataMap
    }
    
    public func getPathPixelDataIsLoaded() -> [String: PathPixelDataIsLoaded] {
        return TJLabsPathPixelManager.ppDataLoaded
    }
    
    public func getScaleOffset() -> [String: [Double]] {
        return TJLabsScaleOffsetManager.scaleOffsetDataMap
    }
    
    // MARK: - Public Update Methods
    public func updatePathPixelData(key: String, URL: String) {
        TJLabsPathPixelManager.isPerformed = true
        self.pathPixelManager.updatePathPixel(key: key, pathPixelUrlFromServer: URL)
    }
    
    // MARK: - Private Methods
    private func loadBuildingLevel(region: ResourceRegion, sectorId: Int, completion: @escaping (Bool, [String: [String]]) -> Void) {
        buildingLevelManager.loadBuildingLevel(region: region, sectorId: sectorId, completion: { [self] isSuccess, buildingLevelData in
            if isSuccess {
                delegate?.onBuildingLevelData(self, buildingLevelData: buildingLevelData)
            }
            completion(isSuccess, buildingLevelData)
        })
    }
    
    private func loadPathPixel(region: ResourceRegion, sectorId: Int) {
        if !TJLabsPathPixelManager.isPerformed {
            TJLabsPathPixelManager.isPerformed = true
            pathPixelManager.loadPathPixel(sectorId: sectorId)
        } else {
            print("(TJLabsResource) Info : loadPathPixel already performed")
        }
    }
    
    private func loadImage(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func loadScaleOffset(region: ResourceRegion, sectorId: Int) {
        if !TJLabsScaleOffsetManager.isPerformed {
            TJLabsScaleOffsetManager.isPerformed = true
            scaleOffsetManager.loadScaleOffset(region: region, sectorId: sectorId)
        } else {
            print("(TJLabsResource) Info : loadScaleOffset already performed")
        }
    }
    
    private func loadUnit(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func loadRouteTrack(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func setRegion(region: ResourceRegion) {
        TJLabsResourceNetworkConstants.setServerURL(region: region)
        TJLabsFileDownloader.shared.setRegion(region: region)
        pathPixelManager.setRegion(region: region)
        buildingLevelManager.setRegion(region: region)
    }
}
