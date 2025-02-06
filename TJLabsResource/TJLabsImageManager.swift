
import Foundation

class TJLabsImageManager {
    static var isPerformed: Bool = false
    
//    static var buildingLevelDataMap = [Int: [String: [String]]]()
    
    var region: ResourceRegion = .KOREA
    
    init() { }
    
    func setRegion(region: ResourceRegion) {
        self.region = region
    }
    
    func loadBuildingLevel(region: ResourceRegion, sectorId: Int) {
        let input = SectorIdInput(sector_id: sectorId)
        TJLabsResourceNetworkManager.shared.postBuildingLevel(url: TJLabsResourceNetworkConstants.getUserLevelURL(), input: input, completion: { [self] statusCode, returnedString, inputSector in
            if statusCode == 200 {
                // Success
            } else {
                // Fail
                print("(TJLabsResource) Fail : loadBuildingLevel")
            }
        })
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
