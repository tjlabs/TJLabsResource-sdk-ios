
import Foundation

class TJLabsBuildingLevelManager {
    static var buildingLevelDataMap = [Int: [String: [String]]]()
    
    var region: ResourceRegion = .KOREA
    
    init() { }
    
    func setRegion(region: ResourceRegion) {
        self.region = region
    }
    
    func loadBuildingLevel(region: ResourceRegion, sectorId: Int, completion: @escaping (Bool, [String: [String]]) -> Void) {
        var result = [String: [String]]()
        
        if let data = TJLabsBuildingLevelManager.buildingLevelDataMap[sectorId] {
            completion(true, data)
        } else {
            let input = SectorIdInput(sector_id: sectorId)
            TJLabsResourceNetworkManager.shared.postBuildingLevel(url: TJLabsResourceNetworkConstants.getUserLevelURL(), input: input, completion: { [self] statusCode, returnedString, inputBuilidngLevel in
                if statusCode == 200 {
                    // Success
                    let decodedInfo = decodeLevelOutputList(jsonString: returnedString)
                    if decodedInfo.0 {
                        let buildingLevelInfo = makeBuildingLevelInfo(sector_id: sectorId, outputLevel: decodedInfo.1)
                        result = buildingLevelInfo
                        setBuildingLevelDataMap(sectorId: sectorId, buildingLevelInfo: buildingLevelInfo)
                        print("(TJLabsResource) Success : loadBuildingLevel")
                        completion(true, result)
                    } else {
                        print("(TJLabsResource) Fail : error in decoding loadBuildingLevel")
                        completion(false, result)
                    }
                } else {
                    // Fail
                    print("(TJLabsResource) Fail : loadBuildingLevel")
                    completion(false, result)
                }
            })
        }
    }
    
    func setBuildingLevelDataMap(sectorId: Int, buildingLevelInfo: [String: [String]]) {
        TJLabsBuildingLevelManager.buildingLevelDataMap[sectorId] = TJLabsBuildingLevelManager.buildingLevelDataMap[sectorId] ?? buildingLevelInfo
        print("(TJLabsResourece) : buildingLevelDataMap = \(TJLabsBuildingLevelManager.buildingLevelDataMap)")
    }
    
    private func makeBuildingLevelInfo(sector_id: Int, outputLevel: LevelOutputList) -> [String: [String]] {
        //MARK: - Level
        var infoBuildingLevel = [String:[String]]()
        for element in outputLevel.level_list {
            let buildingName = element.building_name
            let levelName = element.level_name
            
            if !levelName.contains("_D") {
                if var levels = infoBuildingLevel[buildingName] {
                    levels.append(levelName)
                    infoBuildingLevel[buildingName] = levels.sorted(by: { lhs, rhs in
                        return compareFloorNames(lhs: lhs, rhs: rhs)
                    })
                } else {
                    let levels = [levelName]
                    infoBuildingLevel[buildingName] = levels
                }
            }
        }
        return infoBuildingLevel
    }
    
    private func compareFloorNames(lhs: String, rhs: String) -> Bool {
        func floorValue(_ floor: String) -> Int {
            if floor.starts(with: "B"), let number = Int(floor.dropFirst()) {
                return -number
            } else if floor.hasSuffix("F"), let number = Int(floor.dropLast()) {
                return number
            }
            return 0
        }
        
        return floorValue(lhs) > floorValue(rhs)
    }
    
    // MARK: - Decoding
    private func decodeLevelOutputList(jsonString: String) -> (Bool, LevelOutputList) {
        let result = LevelOutputList(level_list: [])
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let decodedData: LevelOutputList = try JSONDecoder().decode(LevelOutputList.self, from: jsonData)
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
