
import Foundation
import UIKit

protocol BuildingLevelImageDelegate: AnyObject {
    func onBuildingLevelImageData(_ manager: TJLabsImageManager, isOn: Bool, imageKey: String, data: UIImage?)
}

class TJLabsImageManager {
    static var buildingLevelImageDataMap = [String: UIImage]()
    weak var delegate: BuildingLevelImageDelegate?
    
    var region: String = ResourceRegion.KOREA.rawValue
    var baseURL: String = ""
    
    init() {
        self.baseURL = TJLabsResourceNetworkConstants.getImageBaseURL()
    }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func loadImage(region: String, sectorId: Int, buildingLevelData: [String: [String]]) {
        for (key, value) in buildingLevelData {
            let buildingName = key
            let levelNameList: [String] = value
            for levelName in levelNameList {
                if !levelName.contains("_D") {
                    let imageKey = "image_\(sectorId)_\(buildingName)_\(levelName)"
                    self.loadBuildingLevelImage(sector_id: sectorId, building: buildingName, level: levelName, completion: { [self] data, error in
                        if let imageData = data {
                            TJLabsImageManager.buildingLevelImageDataMap[imageKey] = imageData
                            delegate?.onBuildingLevelImageData(self, isOn: true, imageKey: imageKey, data: imageData)
                        } else {
                            delegate?.onBuildingLevelImageData(self, isOn: false, imageKey: imageKey, data: nil)
                        }
                    })
                }
            }
        }
    }
    
    private func loadBuildingLevelImage(sector_id: Int, building: String, level: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let urlString: String = "\(baseURL)/map/\(sector_id)/\(building)/\(level).png"
        print("(TJLabsResource) Info : Sector Image URL = \(urlString)")
        if let urlLevel = URL(string: urlString) {
            let cacheKey = NSString(string: urlString)
            if let cachedImage = TJLabsImageCacheManager.shared.object(forKey: cacheKey) {
                completion(cachedImage, nil)
            } else {
                let task = URLSession.shared.dataTask(with: urlLevel) { (data, response, error) in
                    if let error = error {
                        completion(nil, error)
                    }
                    
                    if let data = data, let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            if let imageData = UIImage(data: data) {
                                TJLabsImageCacheManager.shared.setObject(imageData, forKey: cacheKey)
                                completion(UIImage(data: data), nil)
                            } else {
                                completion(nil, error)
                            }
                        }
                    } else {
                        completion(nil, error)
                    }
                }
                task.resume()
            }
        } else {
            completion(nil, nil)
        }
    }
}
