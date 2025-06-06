
import Foundation

protocol ScaleOffsetDelegate: AnyObject {
    func onScaleOffsetData(_ manager: TJLabsScaleOffsetManager, isOn: Bool, scaleKey: String, data: [Double]?)
    func onScaleError(_ manager: TJLabsScaleOffsetManager)
}

class TJLabsScaleOffsetManager {
    static var scaleOffsetDataMap = [String: [Double]]()
    weak var delegate: ScaleOffsetDelegate?
    
    var region: String = ResourceRegion.KOREA.rawValue
    
    init() { }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func loadScaleOffset(region: String, sectorId: Int) {
        let input = SectorIdOsInput(sector_id: sectorId, operating_system: "iOS")
        TJLabsResourceNetworkManager.shared.postScaleOffset(url: TJLabsResourceNetworkConstants.getUserScaleURL(), input: input, completion: { [self] statusCode, returnedString, scaleInput in
            if statusCode == 200 {
                // Success
                let decodedInfo = decodeScaleOutputList(jsonString: returnedString)
                if decodedInfo.0 {
                    updateScaleOffset(sectorId: sectorId, scaleOutputList: decodedInfo.1)
                } else {
                    print("(TJLabsResource) Fail : error in decoding loadScaleOffset")
                    delegate?.onScaleError(self)
                }
            } else {
                // Fail
                print("(TJLabsResource) Fail : loadScaleOffset")
                delegate?.onScaleError(self)
            }
        })
    }
    
    func updateScaleOffset(sectorId: Int, scaleOutputList: ScaleOutputList) {
        let scaleList = scaleOutputList.scale_list
        for element in scaleList {
            let buildingName = element.building_name
            let levelName = element.level_name
            
            let scaleKey = "scale_\(sectorId)_\(buildingName)_\(levelName)"
            TJLabsScaleOffsetManager.scaleOffsetDataMap[scaleKey] = element.image_scale
            delegate?.onScaleOffsetData(self, isOn: true, scaleKey: scaleKey, data: element.image_scale)
        }
    }
    
    // MARK: - Decoding
    private func decodeScaleOutputList(jsonString: String) -> (Bool, ScaleOutputList) {
        let result = ScaleOutputList(scale_list: [])
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let decodedData: ScaleOutputList = try JSONDecoder().decode(ScaleOutputList.self, from: jsonData)
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
