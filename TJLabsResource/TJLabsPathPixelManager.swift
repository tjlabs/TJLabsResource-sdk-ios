
import Foundation

class TJLabsPathPixelManager {
    static var isPerformed: Bool = false
    
    static var ppDataMap = [String: PathPixelData]()
    static var ppDataLoaded = [String: PathPixelDataIsLoaded]()
    
    var region: ResourceRegion = .KOREA
    
    init() { }
    
    func setRegion(region: ResourceRegion) {
        self.region = region
    }
    
    func loadPathPixel(sectorId: Int, completion: @escaping (Bool, String) -> Void) {
        postUserPath(input: InputSector(sector_id: sectorId, operating_system: "iOS"), completion: { [self] isSuccess, msg, pathPixelURL in
            if isSuccess {
                // 성공
                for (key, value) in pathPixelURL {
                    let pathPixelUrlFromServer = value
                    if let pathPixelUrlFromCache = loadPathPixelUrlFromCache(key: key) {
                        if pathPixelUrlFromServer == pathPixelUrlFromCache {
                            // 버전이 같다면
                            if let fileUrlFromCache = self.loadPathPixelFileUrlFromCache(key: key) {
                                // Cache에서 파일 URL 가져오기 성공
                                do {
                                    let contents = try String(contentsOf: fileUrlFromCache)
                                    TJLabsPathPixelManager.ppDataMap[key] = self.parsePathPixelData(data: contents)
                                    TJLabsPathPixelManager.ppDataLoaded[key] = PathPixelDataIsLoaded(isLoaded: true, URL: pathPixelUrlFromServer)
                                } catch {
                                    updatePathPixel(key: key, pathPixelUrlFromServer: pathPixelUrlFromServer)
                                }
                            } else {
                                // Cache에서 파일 URL 가져오기 실패
                                updatePathPixel(key: key, pathPixelUrlFromServer: pathPixelUrlFromServer)
                            }
                        } else {
                            // 버전이 다르다면 서버에서 다운로드
                            updatePathPixel(key: key, pathPixelUrlFromServer: pathPixelUrlFromServer)
                        }
                    } else {
                        // Cache에 저장된 정보 없음
                        updatePathPixel(key: key, pathPixelUrlFromServer: pathPixelUrlFromServer)
                    }
                }
                completion(true, "(TJLabsResource) Success : loadPathPixel")
            } else {
                completion(false, "(TJLabsResource) Fail : loadPathPixel")
            }
        })
    }
    
    func updatePathPixel(key: String, pathPixelUrlFromServer: String) {
        let urlComponents = URLComponents(string: pathPixelUrlFromServer)
        TJLabsFileDownloader.shared.downloadCSVFile(from: (urlComponents?.url)!, fname: key, completion: { [self] url, error in
            if error == nil {
                do {
                    let contents = try String(contentsOf: url!)
                    TJLabsPathPixelManager.ppDataMap[key] = self.parsePathPixelData(data: contents)
                    TJLabsPathPixelManager.ppDataLoaded[key] = PathPixelDataIsLoaded(isLoaded: true, URL: pathPixelUrlFromServer)
                    self.savePathPixelUrlToCache(key: key, pathPixelUrlFromServer: pathPixelUrlFromServer)
                } catch {
                    TJLabsPathPixelManager.ppDataLoaded[key] = PathPixelDataIsLoaded(isLoaded: false, URL: pathPixelUrlFromServer)
                }
            } else {
                TJLabsPathPixelManager.ppDataLoaded[key] = PathPixelDataIsLoaded(isLoaded: false, URL: pathPixelUrlFromServer)
            }
        })
    }
    
    func loadPathPixelFileUrlFromCache(key: String) -> URL? {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedURL = documentsURL.appendingPathComponent("\(self.region.rawValue)/\(key).csv")
            
            if FileManager.default.fileExists(atPath: savedURL.path) {
                print("(TJLabsResource) Info : Path-Pixel \(key).csv exists")
                return savedURL
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func loadPathPixelUrlFromCache(key: String) -> String? {
        let keyPpURL: String = "TJLabsPathPixelURL_\(key)"
        if let loadedPpURL: String = UserDefaults.standard.object(forKey: keyPpURL) as? String {
            return loadedPpURL
        } else {
            return nil
        }
    }
    
    func savePathPixelUrlToCache(key: String, pathPixelUrlFromServer: String) {
        print("(TJLabsResource) Info : save \(key) Path-Pixel URL \(pathPixelUrlFromServer)")
        do {
            let key: String = "TJLabsPathPixelURL_\(key)"
            UserDefaults.standard.set(pathPixelUrlFromServer, forKey: key)
        }
    }
    
    func postUserPath(input: InputSector, completion: @escaping (Bool, String, [String: String]) -> Void) {
       var pathPixelURL = [String: String]()
        let pathURL = TJLabsResourceNetworkConstants.getUserPathPixelURL()
        TJLabsResourceNetworkManager.shared.postPathPixel(url: pathURL, input: input, completion: { [self] statusCode, returnedString, input in
            if statusCode == 200 {
                let outputPath = decodeOutputPathPixel(jsonString: returnedString)
                if outputPath.0 {
                    //MARK: - Path
                    let pathInfo = outputPath.1
                    for element in pathInfo.path_pixel_list {
                        let buildingName = element.building_name
                        let levelName = element.level_name
                        let key = "\(input.sector_id)_\(buildingName)_\(levelName)"
                        let ppURL = element.url
                        
                        // Path-Pixel URL 저장
                        pathPixelURL[key] = ppURL
                        print("(TJLabsResource) Info : \(key) PP URL = \(ppURL)")
                    }
                    let msg = "(TJLabsResource) Success : Load Sector Info // Path"
                    completion(true, msg, pathPixelURL)
                } else {
                    let msg = "(TJLabsResource) Error : Load Sector Info // Path \(statusCode)"
                    completion(false, msg, pathPixelURL)
                }
            } else {
                let msg = "(TJLabsResource) Error : Load Sector Info // Path \(statusCode)"
                completion(false, msg, pathPixelURL)
            }
        })
    }
    
    // MARK: - Decode FLT output
    func decodeOutputPathPixel(jsonString: String) -> (Bool, OutputPathPixel) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return (false, OutputPathPixel(path_pixel_list: []))
        }
        
        do {
            let decodedData = try JSONDecoder().decode(OutputPathPixel.self, from: jsonData)
            return (true, decodedData)
        } catch {
            print("Error decoding JSON: \(error)")
            return (false, OutputPathPixel(path_pixel_list: []))
        }
    }
    
    // MARK: - Parsing
    func parsePathPixelData(data: String) -> PathPixelData {
        var roadType = [Int]()
        var nodeNumber = [Int]()
        var road = [[Double]]()
        var roadMinMax = [Double]()
        var roadScale = [Double]()
        var roadHeading = [String]()
        var roadX = [Double]()
        var roadY = [Double]()
        
        let roadString = data.components(separatedBy: .newlines)
        for i in 0..<roadString.count {
            if (roadString[i] != "") {
                let lineString = roadString[i]
                let lineData = roadString[i].components(separatedBy: ",")
                
                let typeString = lineData[0]
                let nodeString = lineData[1]
                let xString = lineData[2]
                let yString = lineData[3]
                let scaleString = lineData[4]
                
                if !xString.isEmpty && !yString.isEmpty {
                    roadType.append(Int(Double(typeString)!))
                    nodeNumber.append(Int(Double(nodeString)!))
                    roadX.append(Double(xString)!)
                    roadY.append(Double(yString)!)
                    roadScale.append(Double(scaleString)!)
                    
                    let pattern = "\\[[^\\]]+\\]"
                    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                        print("Invalid regular expression pattern")
                        exit(1)
                    }
                    let matches = regex.matches(in: lineString, options: [], range: NSRange(location: 0, length: lineString.utf16.count))
                    let matchedStrings = matches.map { match -> String in
                        let range = Range(match.range, in: lineString)!
                        return String(lineString[range])
                    }
                    
                    var headingValues = ""
                    if (!matchedStrings.isEmpty) {
                        let headingListString = matchedStrings[0]
                        let headingArray = headingListString
                            .replacingOccurrences(of: "[", with: "")
                            .replacingOccurrences(of: "]", with: "")
                            .components(separatedBy: ",")
                            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                        
                        for j in 0..<headingArray.count {
                            headingValues.append(String(headingArray[j]))
                            if (j < (headingArray.count-1)) {
                                headingValues.append(",")
                            }
                        }
                    }
                    roadHeading.append(headingValues)
                }
            }
        }
        road = [roadX, roadY]
        roadMinMax = [roadX.min() ?? 0, roadY.min() ?? 0, roadX.max() ?? 0, roadY.max() ?? 0]
        
        return PathPixelData(roadType: roadType, nodeNumber: nodeNumber, road: road, roadMinMax: roadMinMax, roadScale: roadScale, roadHeading: roadHeading)
    }
}
