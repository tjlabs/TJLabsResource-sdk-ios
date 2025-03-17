
import Foundation

protocol UnitDelegate: AnyObject {
    func onUnitData(_ manager: TJLabsUnitManager, isOn: Bool, unitKey: String, data: [UnitData]?)
    func onUnitError(_ manager: TJLabsUnitManager)
}

class TJLabsUnitManager {
    static var unitDataMap = [String: [UnitData]]()
    weak var delegate: UnitDelegate?
    
    var region: String = ResourceRegion.KOREA.rawValue
    
    init() { }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func loadUnits(region: String, sectorId: Int) {
        let input = SectorIdInput(sector_id: sectorId)
        TJLabsResourceNetworkManager.shared.postUnit(url: TJLabsResourceNetworkConstants.getUserUnitURL(), input: input, completion: { [self] statusCode, returnedString, unitInput in
            if statusCode == 200 {
                // Success
                let decodedInfo = decodeUnitOutputList(jsonString: returnedString)
                if decodedInfo.0 {
                    updateUnits(sectorId: sectorId, unitOutputList: decodedInfo.1)
                } else {
                    print("(TJLabsResource) Fail : error in decoding loadUnits")
                    delegate?.onUnitError(self)
                }
            } else {
                // Fail
                print("(TJLabsResource) Fail : loadUnits")
                delegate?.onUnitError(self)
            }
        })
    }
    
    func updateUnits(sectorId: Int, unitOutputList: UnitOutputList) {
        let unitList = unitOutputList.unit_list
        for element in unitList {
            let buildingName = element.building_name
            let levelName = element.level_name
            
            let unitKey = "unit_\(sectorId)_\(buildingName)_\(levelName)"
            TJLabsUnitManager.unitDataMap[unitKey] = element.units
            delegate?.onUnitData(self, isOn: true, unitKey: unitKey, data: element.units)
        }
    }
    
    // MARK: - Decoding
    private func decodeUnitOutputList(jsonString: String) -> (Bool, UnitOutputList) {
        let result = UnitOutputList(unit_list: [])
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let decodedData: UnitOutputList = try JSONDecoder().decode(UnitOutputList.self, from: jsonData)
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
