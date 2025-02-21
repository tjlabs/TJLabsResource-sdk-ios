
import Foundation
import UIKit

public class TJLabsResourceManager: BuildingLevelDelegate, PathPixelDelegate, BuildingLevelImageDelegate, ScaleOffsetDelegate, EntranceDelegate {
    func onBuildingLevelData(_ manager: TJLabsBuildingLevelManager, isOn: Bool, buildingLevelData: [String: [String]]) {
        delegate?.onBuildingLevelData(self, isOn: isOn, buildingLevelData: buildingLevelData)
        print("(TJLabsResource) Info : onBuildingLevelData // isOn = \(isOn) , buildingLevelData = \(buildingLevelData)")
    }
    
    func onBuildingLevelError(_ manager: TJLabsBuildingLevelManager) {
        delegate?.onError(self, error: .BuildingLevel)
        print("(TJLabsResource) Info : onBuildingLevelError")
    }
    
    func onPathPixelData(_ manager: TJLabsPathPixelManager, isOn: Bool, pathPixelKey: String) {
        delegate?.onPathPixelData(self, isOn: isOn, pathPixelKey: pathPixelKey)
        print("(TJLabsResource) Info : onPathPixelData // isOn = \(isOn) , pathPixelKey = \(pathPixelKey)")
    }
    
    func onPathPixelError(_ manager: TJLabsPathPixelManager) {
        delegate?.onError(self, error: .PathPixel)
        print("(TJLabsResource) Info : onPathPixelError")
    }
    
    func onBuildingLevelImageData(_ manager: TJLabsImageManager, isOn: Bool, imageKey: String) {
        delegate?.onBuildingLevelImageData(self, isOn: isOn, imageKey: imageKey)
        print("(TJLabsResource) Info : onBuildingLevelImageData // isOn = \(isOn) , imageKey = \(imageKey)")
    }
    
    func onScaleOffsetData(_ manager: TJLabsScaleOffsetManager, isOn: Bool, scaleKey: String) {
        delegate?.onScaleOffsetData(self, isOn: isOn, scaleKey: scaleKey)
        print("(TJLabsResource) Info : onScaleOffsetData // isOn = \(isOn) , scaleKey = \(scaleKey)")
    }
    
    func onScaleError(_ manager: TJLabsScaleOffsetManager) {
        delegate?.onError(self, error: .Scale)
        print("(TJLabsResource) Info : onScaleError")
    }
    
    func onEntranceData(_ manager: TJLabsEntranceManager, isOn: Bool, entranceKey: String) {
        delegate?.onEntranceData(self, isOn: isOn, entranceKey: entranceKey)
        print("(TJLabsResource) Info : onEntranceData // isOn = \(isOn) , entranceKey = \(entranceKey)")
    }
    
    func onEntranceError(_ manager: TJLabsEntranceManager) {
        delegate?.onError(self, error: .Entrance)
        print("(TJLabsResource) Info : onEntranceError")
    }
    
    public static let shared = TJLabsResourceManager()
    public weak var delegate: TJLabsResourceManagerDelegate?
    
    let buildingLevelManager = TJLabsBuildingLevelManager()
    let pathPixelManager = TJLabsPathPixelManager()
    let entranceManager = TJLabsEntranceManager()
    let imageManager = TJLabsImageManager()
    let scaleOffsetManager = TJLabsScaleOffsetManager()
    
    public init() {
        buildingLevelManager.delegate = self
        pathPixelManager.delegate = self
        scaleOffsetManager.delegate = self
        imageManager.delegate = self
        entranceManager.delegate = self
    }
    
    // MARK: - Public Methods
    public func loadMapResource(region: ResourceRegion, sectorId: Int) {
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadImage(region: region, sectorId: sectorId)
        self.loadScaleOffset(region: region, sectorId: sectorId)
        self.loadUnit(region: region, sectorId: sectorId)
    }
    
    public func loadJupiterResource(region: ResourceRegion, sectorId: Int) {
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadEntrance(region: region, sectorId: sectorId)
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
    
    public func getBuildingLevelImageData() -> [String: UIImage] {
        return TJLabsImageManager.buildingLevelImageDataMap
    }
    
    public func getEntranceNumbers() -> Int {
        return TJLabsEntranceManager.entranceNumbers
    }
    
    public func getEntranceData() -> [String: EntranceData] {
        return TJLabsEntranceManager.entranceDataMap
    }
    
    public func getEntranceRouteData() -> [String: EntranceRouteData] {
        return TJLabsEntranceManager.entranceRouteDataMap
    }
    
    public func getEntranceRouteDataIsLoaded() -> [String: EntranceRouteDataIsLoaded] {
        return TJLabsEntranceManager.entranceRouteDataLoaded
    }
    
    public func getEntranceOuterwards() -> [String] {
        return TJLabsEntranceManager.entranceOuterWards
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
            pathPixelManager.loadPathPixel(sectorId: sectorId)
        } else {
            print("(TJLabsResource) Info : loadPathPixel already performed")
        }
    }
    
    private func loadBuildingLevel(region: ResourceRegion, sectorId: Int, completion: @escaping (Bool, [String: [String]]) -> Void) {
        buildingLevelManager.loadBuildingLevel(region: region, sectorId: sectorId, completion: completion)
    }
    
    private func loadImage(region: ResourceRegion, sectorId: Int) {
        self.loadBuildingLevel(region: region, sectorId: sectorId, completion: { [self] isSuccess, buildingLevelData in
            if isSuccess {
                self.imageManager.loadImage(region: region, sectorId: sectorId, buildingLevelData: buildingLevelData)
            }
        })
    }
    
    private func loadScaleOffset(region: ResourceRegion, sectorId: Int) {
        scaleOffsetManager.loadScaleOffset(region: region, sectorId: sectorId)
    }
    
    private func loadUnit(region: ResourceRegion, sectorId: Int) {
        
    }
    
    private func loadEntrance(region: ResourceRegion, sectorId: Int) {
        entranceManager.loadEntrance(sectorId: sectorId)
    }
    
    private func setRegion(region: ResourceRegion) {
        TJLabsResourceNetworkConstants.setServerURL(region: region)
        TJLabsFileDownloader.shared.setRegion(region: region)
        buildingLevelManager.setRegion(region: region)
        imageManager.setRegion(region: region)
        scaleOffsetManager.setRegion(region: region)
        pathPixelManager.setRegion(region: region)
        entranceManager.setRegion(region: region)
    }
}
