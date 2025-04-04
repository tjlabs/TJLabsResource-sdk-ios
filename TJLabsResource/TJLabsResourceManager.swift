
import Foundation
import UIKit

public class TJLabsResourceManager: BuildingLevelDelegate, PathPixelDelegate, BuildingLevelImageDelegate, ScaleOffsetDelegate, EntranceDelegate, UnitDelegate, ParamDelegate, GeofenceDelegate {
    

    func onBuildingLevelData(_ manager: TJLabsBuildingLevelManager, isOn: Bool, buildingLevelData: [String: [String]]) {
        delegate?.onBuildingLevelData(self, isOn: isOn, buildingLevelData: buildingLevelData)
        print("(TJLabsResource) Info : onBuildingLevelData // isOn = \(isOn) , buildingLevelData = \(buildingLevelData)")
    }
    
    func onBuildingLevelError(_ manager: TJLabsBuildingLevelManager) {
        delegate?.onError(self, error: .BuildingLevel)
        print("(TJLabsResource) Info : onBuildingLevelError")
    }
    
    func onPathPixelData(_ manager: TJLabsPathPixelManager, isOn: Bool, pathPixelKey: String, data: PathPixelData?) {
        delegate?.onPathPixelData(self, isOn: isOn, key: pathPixelKey, data: data)
        print("(TJLabsResource) Info : onPathPixelData // isOn = \(isOn) , pathPixelKey = \(pathPixelKey)")
    }
    
    func onPathPixelDataLoaded(_ manager: TJLabsPathPixelManager, isOn: Bool, pathPixelKey: String, data: PathPixelDataIsLoaded?) {
        delegate?.onPathPixelDataLoaded(self, isOn: isOn, key: pathPixelKey, data: data)
        print("(TJLabsResource) Info : onPathPixelDataLoaded // isOn = \(isOn) , pathPixelKey = \(pathPixelKey)")
    }
    
    func onPathPixelError(_ manager: TJLabsPathPixelManager) {
        delegate?.onError(self, error: .PathPixel)
        print("(TJLabsResource) Info : onPathPixelError")
    }
    
    func onBuildingLevelImageData(_ manager: TJLabsImageManager, isOn: Bool, imageKey: String, data: UIImage?) {
        delegate?.onBuildingLevelImageData(self, isOn: isOn, key: imageKey, data: data)
        print("(TJLabsResource) Info : onBuildingLevelImageData // isOn = \(isOn) , imageKey = \(imageKey)")
    }
    
    func onScaleOffsetData(_ manager: TJLabsScaleOffsetManager, isOn: Bool, scaleKey: String, data: [Double]?) {
        delegate?.onScaleOffsetData(self, isOn: isOn, key: scaleKey, data: data)
        print("(TJLabsResource) Info : onScaleOffsetData // isOn = \(isOn) , scaleKey = \(scaleKey)")
    }
    
    func onScaleError(_ manager: TJLabsScaleOffsetManager) {
        delegate?.onError(self, error: .Scale)
        print("(TJLabsResource) Info : onScaleError")
    }
    
    func onEntranceData(_ manager: TJLabsEntranceManager, isOn: Bool, entranceKey: String, data: EntranceData?) {
        delegate?.onEntranceData(self, isOn: isOn, key: entranceKey, data: data)
        print("(TJLabsResource) Info : onEntranceData // isOn = \(isOn) , entranceKey = \(entranceKey)")
    }
    
    func onEntranceRouteData(_ manager: TJLabsEntranceManager, isOn: Bool, entranceKey: String, data: EntranceRouteData?) {
        delegate?.onEntranceRouteData(self, isOn: isOn, key: entranceKey, data: data)
        print("(TJLabsResource) Info : onEntranceRouteData // isOn = \(isOn) , entranceKey = \(entranceKey)")
    }
    
    func onEntranceError(_ manager: TJLabsEntranceManager) {
        delegate?.onError(self, error: .Entrance)
        print("(TJLabsResource) Info : onEntranceError")
    }
    
    func onUnitData(_ manager: TJLabsUnitManager, isOn: Bool, unitKey: String, data: [UnitData]?) {
        delegate?.onUnitData(self, isOn: isOn, key: unitKey, data: data)
        print("(TJLabsResource) Info : onUnitData // isOn = \(isOn) , unitKey = \(unitKey)")
    }
    
    func onUnitError(_ manager: TJLabsUnitManager) {
        delegate?.onError(self, error: .Unit)
        print("(TJLabsResource) Info : onUnitError")
    }
    
    func onParamData(_ manager: TJLabsParamManager, isOn: Bool, data: ParameterData?) {
        delegate?.onParamData(self, isOn: isOn, data: data)
    }
    
    func onParamError(_ manager: TJLabsParamManager) {
        delegate?.onError(self, error: .Param)
        print("(TJLabsResource) Info : onParamError")
    }
    
    func onGeofenceData(_ manager: TJLabsGeofenceManager, isOn: Bool, geofenceKey: String, data: GeofenceData?) {
        delegate?.onGeofenceData(self, isOn: isOn, key: geofenceKey, data: data)
        print("(TJLabsResource) Info : onGeofenceData // isOn = \(isOn) , geofenceKey = \(geofenceKey)")
    }
    
    func onGeofenceError(_ manager: TJLabsGeofenceManager) {
        delegate?.onError(self, error: .Geofence)
        print("(TJLabsResource) Info : onGeofenceError")
    }
    
    public static let shared = TJLabsResourceManager()
    public weak var delegate: TJLabsResourceManagerDelegate?
    
    let buildingLevelManager = TJLabsBuildingLevelManager()
    let pathPixelManager = TJLabsPathPixelManager()
    let scaleOffsetManager = TJLabsScaleOffsetManager()
    let imageManager = TJLabsImageManager()
    let entranceManager = TJLabsEntranceManager()
    let unitManager = TJLabsUnitManager()
    let paramManager = TJLabsParamManager()
    let geofenceManager = TJLabsGeofenceManager()
    
    public init() {
        buildingLevelManager.delegate = self
        pathPixelManager.delegate = self
        scaleOffsetManager.delegate = self
        imageManager.delegate = self
        entranceManager.delegate = self
        unitManager.delegate = self
        paramManager.delegate = self
        geofenceManager.delegate = self
    }
    
    // MARK: - Public Methods
    public func loadMapResource(region: String, sectorId: Int) {
        self.setRegion(region: region)
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadImage(region: region, sectorId: sectorId)
        self.loadScaleOffset(region: region, sectorId: sectorId)
        self.loadUnit(region: region, sectorId: sectorId)
    }
    
    public func loadJupiterResource(region: String, sectorId: Int) {
        self.setRegion(region: region)
        self.loadPathPixel(region: region, sectorId: sectorId)
        self.loadEntrance(region: region, sectorId: sectorId)
        self.loadParam(region: region, sectorId: sectorId)
        self.loadGeofence(region: region, sectorId: sectorId)
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
    
    public func getEntranceData() -> [String: EntranceData] {
        return TJLabsEntranceManager.entranceDataMap
    }
    
    public func getEntranceRouteData() -> [String: EntranceRouteData] {
        return TJLabsEntranceManager.entranceRouteDataMap
    }
    
    public func getEntranceRouteDataIsLoaded() -> [String: EntranceRouteDataIsLoaded] {
        return TJLabsEntranceManager.entranceRouteDataLoaded
    }
    
    public func getUnitData() -> [String: [UnitData]] {
        return TJLabsUnitManager.unitDataMap
    }
    
    public func getParamData() -> ParameterData {
        return TJLabsParamManager.paramData
    }
    
    public func getGeofenceData() -> [String: GeofenceData] {
        return TJLabsGeofenceManager.geofenceDataMap
    }
    
    // MARK: - Public Update Methods
    public func updatePathPixelData(key: String, URL: String) {
        TJLabsPathPixelManager.isPerformed = true
        self.pathPixelManager.updatePathPixel(key: key, pathPixelUrlFromServer: URL)
    }
    
    // MARK: - Private Methods
    private func loadPathPixel(region: String, sectorId: Int) {
        if !TJLabsPathPixelManager.isPerformed {
            TJLabsPathPixelManager.isPerformed = true
            pathPixelManager.loadPathPixel(sectorId: sectorId)
        } else {
            print("(TJLabsResource) Info : loadPathPixel already performed")
        }
    }
    
    private func loadBuildingLevel(region: String, sectorId: Int, completion: @escaping (Bool, [String: [String]]) -> Void) {
        buildingLevelManager.loadBuildingLevel(region: region, sectorId: sectorId, completion: completion)
    }
    
    private func loadImage(region: String, sectorId: Int) {
        self.loadBuildingLevel(region: region, sectorId: sectorId, completion: { [self] isSuccess, buildingLevelData in
            if isSuccess {
                self.imageManager.loadImage(region: region, sectorId: sectorId, buildingLevelData: buildingLevelData)
            }
        })
    }
    
    private func loadScaleOffset(region: String, sectorId: Int) {
        scaleOffsetManager.loadScaleOffset(region: region, sectorId: sectorId)
    }
    
    private func loadUnit(region: String, sectorId: Int) {
        unitManager.loadUnits(region: region, sectorId: sectorId)
    }
    
    private func loadEntrance(region: String, sectorId: Int) {
        entranceManager.loadEntrance(region: region, sectorId: sectorId)
    }
    
    private func loadParam(region: String, sectorId: Int) {
        paramManager.loadParam(region: region, sectorId: sectorId)
    }
    
    private func loadGeofence(region: String, sectorId: Int) {
        geofenceManager.loadGeofence(region: region, sectorId: sectorId)
    }
    
    private func setRegion(region: String) {
        TJLabsResourceNetworkConstants.setServerURL(region: region)
        TJLabsFileDownloader.shared.setRegion(region: region)
        buildingLevelManager.setRegion(region: region)
        imageManager.setRegion(region: region)
        scaleOffsetManager.setRegion(region: region)
        pathPixelManager.setRegion(region: region)
        entranceManager.setRegion(region: region)
        unitManager.setRegion(region: region)
        paramManager.setRegion(region: region)
        geofenceManager.setRegion(region: region)
    }
}
