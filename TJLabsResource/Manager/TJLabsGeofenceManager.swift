
import Foundation

protocol GeofenceDelegate: AnyObject {
    func onGeofenceData(_ manager: TJLabsGeofenceManager, isOn: Bool, geofenceKey: String, data: GeofenceData?)
    func onGeofenceError(_ manager: TJLabsGeofenceManager)
}

class TJLabsGeofenceManager {
    static var geofenceDataMap = [String: GeofenceData]()
    weak var delegate: GeofenceDelegate?
    
    var region: String = ResourceRegion.KOREA.rawValue
    
    init() { }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func loadGeofence(region: String, sectorId: Int) {
        let input = SectorIdOsInput(sector_id: sectorId, operating_system: "iOS")
        TJLabsResourceNetworkManager.shared.postGeo(url: TJLabsResourceNetworkConstants.getUserParamURL(), input: input, completion: { [self] statusCode, returnedString, geoInput in
            if statusCode == 200 {
                // Success
                let decodedInfo = decodeGeofenceOutputList(jsonString: returnedString)
                if decodedInfo.0 {
                    updateGeofence(sectorId: sectorId, geofenceOutputList: decodedInfo.1)
                } else {
                    print("(TJLabsResource) Fail : error in decoding loadGeofence")
                    delegate?.onGeofenceError(self)
                }
            } else {
                // Fail
                print("(TJLabsResource) Fail : loadGeofence")
                delegate?.onGeofenceError(self)
            }
        })
    }
    
    func updateGeofence(sectorId: Int, geofenceOutputList: GeofenceOutputList) {
        for geofence in geofenceOutputList.geofence_list {
            let buildingName = geofence.building_name
            let levelNamve = geofence.level_name
            let geofenceKey: String = "geofence_\(sectorId)_\(buildingName)_\(levelNamve)"
            
            let entranceArea = geofence.entrance_area
            let entranceMatchingArea = geofence.entrance_matching_area
            let levelChangeArea = geofence.level_change_area
            let drModeArea = geofence.dr_mode_areas
            
            let geofenceData = GeofenceData(entranceArea: entranceArea, entranceMatchingArea: entranceMatchingArea, levelChangeArea: levelChangeArea, drModeArea: drModeArea)
            TJLabsGeofenceManager.geofenceDataMap[geofenceKey] = geofenceData
            delegate?.onGeofenceData(self, isOn: true, geofenceKey: geofenceKey, data: geofenceData)
        }
    }
    
    // MARK: - Decoding
    private func decodeGeofenceOutputList(jsonString: String) -> (Bool, GeofenceOutputList) {
        let result = GeofenceOutputList(geofence_list: [])
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let decodedData: GeofenceOutputList = try JSONDecoder().decode(GeofenceOutputList.self, from: jsonData)
                return (true, decodedData)
            } catch {
                print("Error decoding JSON: \(error)")
                return (false, result)
            }
        } else {
            return (false, result)
        }
    }
}
