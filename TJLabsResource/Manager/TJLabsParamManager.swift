
import Foundation

protocol ParamDelegate: AnyObject {
    func onParamData(_ manager: TJLabsParamManager, isOn: Bool, data: ParameterData?)
    func onParamError(_ manager: TJLabsParamManager)
}

class TJLabsParamManager {
    static var paramData: ParameterData = ParameterData(trajectory_length: 0, trajectory_diagonal: 0, debug: false, standard_rss: [])
    weak var delegate: ParamDelegate?
    
    var region: ResourceRegion = .KOREA
    
    init() { }
    
    func setRegion(region: ResourceRegion) {
        self.region = region
    }
    
    func loadParam(region: ResourceRegion, sectorId: Int) {
        let input = SectorIdOsInput(sector_id: sectorId, operating_system: "iOS")
        TJLabsResourceNetworkManager.shared.postParam(url: TJLabsResourceNetworkConstants.getUserParamURL(), input: input, completion: { [self] statusCode, returnedString, scaleInput in
            if statusCode == 200 {
                // Success
                let decodedInfo = decodeParamOutput(jsonString: returnedString)
                if decodedInfo.0 {
                    updateParam(sectorId: sectorId, paramOutput: decodedInfo.1)
                } else {
                    print("(TJLabsResource) Fail : error in decoding loadParam")
                    delegate?.onParamError(self)
                }
            } else {
                // Fail
                print("(TJLabsResource) Fail : loadParam")
                delegate?.onParamError(self)
            }
        })
    }
    
    func updateParam(sectorId: Int, paramOutput: ParameterOutput) {
        let paramKey: String = "param_\(sectorId)"
        let paramData = ParameterData(trajectory_length: paramOutput.trajectory_length, trajectory_diagonal: paramOutput.trajectory_diagonal, debug: paramOutput.debug, standard_rss: paramOutput.standard_rss)
        TJLabsParamManager.paramData = paramData
        delegate?.onParamData(self, isOn: true, data: paramData)
    }
    
    // MARK: - Decoding
    private func decodeParamOutput(jsonString: String) -> (Bool, ParameterOutput) {
        let result = ParameterOutput(trajectory_length: 0, trajectory_diagonal: 0, debug: false, standard_rss: [])
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let decodedData: ParameterOutput = try JSONDecoder().decode(ParameterOutput.self, from: jsonData)
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
